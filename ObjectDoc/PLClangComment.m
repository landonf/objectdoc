/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLClangComment.h"
#import "PLClangCommentPrivate.h"
#import "PLClangNSString.h"
#import "PLAdditions.h"

typedef CXString (*PLClangCommentGetStringFunction)(CXComment);
typedef unsigned (*PLClangCommentGetNumArgsFunction)(CXComment);
typedef CXString (*PLClangCommentGetArgTextFunction)(CXComment, unsigned);

/**
 * A comment node the in the abstract syntax tree.
 */
@implementation PLClangComment {
    /**
     * A reference to the owning object (the translation unit), held so that the
     * CXComment remains valid for the lifetime of the comment.
     */
    id _owner;

    /** The backing clang comment. */
    CXComment _comment;
}

/**
 * The comment's kind.
 */
- (PLClangCommentKind) kind {
    switch (clang_Comment_getKind(_comment)) {
        case CXComment_Null:
            // Unreachable, returns nil from initializer
            break;

        case CXComment_Text:
            return PLClangCommentKindText;

        case CXComment_InlineCommand:
            return PLClangCommentKindInlineCommand;

        case CXComment_HTMLStartTag:
            return PLClangCommentKindHTMLStartTag;

        case CXComment_HTMLEndTag:
            return PLClangCommentKindHTMLEndTag;

        case CXComment_Paragraph:
            return PLClangCommentKindParagraph;

        case CXComment_BlockCommand:
            return PLClangCommentKindBlockCommand;

        case CXComment_ParamCommand:
            return PLClangCommentKindParamCommand;

        case CXComment_TParamCommand:
            return PLClangCommentKindTParamCommand;

        case CXComment_VerbatimBlockCommand:
            return PLClangCommentKindVerbatimBlockCommand;

        case CXComment_VerbatimBlockLine:
            return PLClangCommentKindVerbatimBlockLine;

        case CXComment_VerbatimLine:
            return PLClangCommentKindVerbatimLine;

        case CXComment_FullComment:
            return PLClangCommentKindFullComment;
    }

    // Comment has an unknown kind
    abort();
}

/**
 * The most appropriate rendering mode for the comment, based on Doxygen's command semantics.
 */
- (PLClangCommentRenderKind) renderKind {
    switch (clang_InlineCommandComment_getRenderKind(_comment)) {
        case CXCommentInlineCommandRenderKind_Normal:
            return PLClangCommentRenderKindNormal;

        case CXCommentInlineCommandRenderKind_Bold:
            return PLClangCommentRenderKindBold;

        case CXCommentInlineCommandRenderKind_Monospaced:
            return PLClangCommentRenderKindMonospaced;

        case CXCommentInlineCommandRenderKind_Emphasized:
            return PLClangCommentRenderKindEmphasized;
    }

    // Comment has an unknown render kind
    abort();
}

- (BOOL) isWhitespace {
    return clang_Comment_isWhitespace(_comment);
}

- (NSString *) description {
    NSMutableString *string = [NSMutableString string];
    [string appendString: [self stringForCommentKind: self.kind]];

    if (self.text) {
        [string appendFormat: @": \"%@\"", self.text];
    }

    if (self.commandName) {
        [string appendFormat:@": %@", self.commandName];
        if ([self.arguments count] > 0) {
            [string appendFormat:@": %@", [self.arguments componentsJoinedByString:@", "]];
        }
    }

    if (self.parameterName) {
        [string appendFormat:@": %@ (%@)", self.parameterName, (self.isParameterIndexValid ? @"valid" : @"invalid")];
    }

    return string;
}

- (NSString *)stringForCommentKind: (PLClangCommentKind) kind {
    #define CKIND(X) case PLClangCommentKind##X: return @#X;
    switch (self.kind) {
        CKIND(Text);
        CKIND(InlineCommand);
        CKIND(HTMLStartTag);
        CKIND(HTMLEndTag);
        CKIND(Paragraph);
        CKIND(BlockCommand);
        CKIND(ParamCommand);
        CKIND(TParamCommand);
        CKIND(VerbatimBlockCommand);
        CKIND(VerbatimBlockLine);
        CKIND(VerbatimLine);
        CKIND(FullComment);
    }
    #undef CKIND
}

@end

/**
 * @internal
 * Package-private methods.
 */
@implementation PLClangComment (PackagePrivate)

/**
 * Initialize a newly-created comment with the specified clang comment.
 *
 * @param comment The clang comment that will back this object.
 * @return An initialized comment or nil if the specified clang comment was null.
 */
- (instancetype) initWithOwner: (id) owner cxComment: (CXComment) comment {
    PLSuperInit();

    enum CXCommentKind kind = clang_Comment_getKind(comment);

    if (kind == CXComment_Null)
        return nil;

    _owner = owner;
    _comment = comment;
    _parameterIndex = NSUIntegerMax;
    _paragraph = [[PLClangComment alloc] initWithOwner: owner cxComment: clang_BlockCommandComment_getParagraph(_comment)];

    PLClangCommentGetNumArgsFunction getNumArgs = NULL;
    PLClangCommentGetArgTextFunction getArgText = NULL;

    /* Extract the text, command name, and parameter name based on the comment kind. */
    switch (kind) {
        case CXComment_Text:
            _text = [self stringForCommentFunction: clang_TextComment_getText];
            break;

        case CXComment_InlineCommand:
            _commandName = [self stringForCommentFunction: clang_InlineCommandComment_getCommandName];
            getNumArgs = clang_InlineCommandComment_getNumArgs;
            getArgText = clang_InlineCommandComment_getArgText;
            break;

        case CXComment_HTMLStartTag:
        case CXComment_HTMLEndTag:
            // TODO: Look up what clang_HTMLTagComment_getAsString() is supposed to do, in libclang 0.20 it returns an empty string.
            //_text = [self stringForCommentFunction: clang_HTMLTagComment_getAsString];

            _text = [self stringForHTMLTag];
            break;

        case CXComment_BlockCommand:
            _commandName = [self stringForCommentFunction: clang_BlockCommandComment_getCommandName];
            getNumArgs = clang_BlockCommandComment_getNumArgs;
            getArgText = clang_BlockCommandComment_getArgText;
            break;

        case CXComment_ParamCommand:
            _parameterName = [self stringForCommentFunction: clang_ParamCommandComment_getParamName];
            _isParameterIndexValid = clang_ParamCommandComment_isParamIndexValid(_comment);
            if (_isParameterIndexValid) {
                _parameterIndex = clang_ParamCommandComment_getParamIndex(_comment);
            }
            break;

        case CXComment_TParamCommand:
            _parameterName = [self stringForCommentFunction: clang_TParamCommandComment_getParamName];
            break;

        case CXComment_VerbatimBlockCommand:
            _commandName = [self stringForCommentFunction: clang_BlockCommandComment_getCommandName];
            break;

        case CXComment_VerbatimBlockLine:
            _text = [self stringForCommentFunction: clang_VerbatimBlockLineComment_getText];
            break;

        case CXComment_VerbatimLine:
            _text = [self stringForCommentFunction: clang_VerbatimLineComment_getText];
            break;

        case CXComment_Null:
        case CXComment_Paragraph:
        case CXComment_FullComment:
            break;
    }

    /* Extract the command arguments, if any. */
    if (getNumArgs && getArgText) {
        unsigned int argCount = getNumArgs(_comment);
        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity: argCount];

        for (unsigned i = 0; i < argCount; i++) {
            [arguments addObject: plclang_convert_and_dispose_cxstring(getArgText(_comment, i))];
        }

        _arguments = arguments;
    }

    /* Recursively extract the child comments */
    unsigned int childCount = clang_Comment_getNumChildren(_comment);
    if (childCount > 0) {
        NSMutableArray *children = [NSMutableArray arrayWithCapacity: childCount];

        for (unsigned int i = 0; i < childCount; i++) {
            [children addObject: [[PLClangComment alloc] initWithOwner: owner cxComment: clang_Comment_getChild(_comment, i)]];
        }

        _children = children;
    }

    return self;
}

/**
 * Returns a string representation of an HTML tag.
 */
- (NSString *)stringForHTMLTag {
    NSMutableString *tag = nil;
    enum CXCommentKind kind = clang_Comment_getKind(_comment);

    if (kind == CXComment_HTMLStartTag) {
        tag = [NSMutableString string];
        [tag appendFormat:@"<%@", [self stringForCommentFunction:clang_HTMLTagComment_getTagName]];

        unsigned count = clang_HTMLStartTag_getNumAttrs(_comment);
        for (unsigned i = 0; i < count; i++) {
            NSString *name = plclang_convert_and_dispose_cxstring(clang_HTMLStartTag_getAttrName(_comment, i));
            NSString *value = plclang_convert_and_dispose_cxstring(clang_HTMLStartTag_getAttrValue(_comment, i));

            if (name && value) {
                [tag appendFormat:@" %@=\"%@\"", name, value];
            }

            if (clang_HTMLStartTagComment_isSelfClosing(_comment)) {
                [tag appendString:@" /"];
            }
        }

        [tag appendString:@">"];
    } else if (kind == CXComment_HTMLEndTag) {
        tag = [NSMutableString stringWithFormat:@"</%@>", [self stringForCommentFunction:clang_HTMLTagComment_getTagName]];
    }

    return tag;
}

/**
 * Returns an NSString for the result of the given comment function.
 */
- (NSString *)stringForCommentFunction: (PLClangCommentGetStringFunction) func {
    return plclang_convert_and_dispose_cxstring(func(_comment));
}

@end
