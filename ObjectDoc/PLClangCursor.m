/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLClangCursor.h"
#import "PLClangCursorPrivate.h"
#import "PLAdditions.h"
#import "PLClangNSString.h"

/**
 * A cursor representing an element in the abstract syntax tree.
 */
@implementation PLClangCursor {
    /** The backing clang cursor. */
    CXCursor _cursor;

    /* Related cursors */
    PLClangCursor *_canonicalCursor;
    PLClangCursor *_semanticParent;
    PLClangCursor *_lexicalParent;
    PLClangCursor *_referencedCursor;
    PLClangCursor *_definition;
}

/**
 * The cursor's kind.
 */
- (PLClangCursorKind) kind {
    switch (_cursor.kind) {
        case CXCursor_UnexposedDecl:
            return PLClangCursorKindUnexposedDeclaration;

        case CXCursor_StructDecl:
            return PLClangCursorKindStructDeclaration;

        case CXCursor_UnionDecl:
            return PLClangCursorKindUnionDeclaration;

        case CXCursor_ClassDecl:
            return PLClangCursorKindClassDeclaration;

        case CXCursor_EnumDecl:
            return PLClangCursorKindEnumDeclaration;

        case CXCursor_FieldDecl:
            return PLClangCursorKindFieldDeclaration;

        case CXCursor_EnumConstantDecl:
            return PLClangCursorKindEnumConstantDeclaration;

        case CXCursor_FunctionDecl:
            return PLClangCursorKindFunctionDeclaration;

        case CXCursor_VarDecl:
            return PLClangCursorKindVariableDeclaration;

        case CXCursor_ParmDecl:
            return PLClangCursorKindParameterDeclaration;

        case CXCursor_ObjCInterfaceDecl:
            return PLClangCursorKindObjCInterfaceDeclaration;

        case CXCursor_ObjCCategoryDecl:
            return PLClangCursorKindObjCCategoryDeclaration;

        case CXCursor_ObjCProtocolDecl:
            return PLClangCursorKindObjCProtocolDeclaration;

        case CXCursor_ObjCPropertyDecl:
            return PLClangCursorKindObjCPropertyDeclaration;

        case CXCursor_ObjCIvarDecl:
            return PLClangCursorKindObjCInstanceVariableDeclaration;

        case CXCursor_ObjCInstanceMethodDecl:
            return PLClangCursorKindObjCInstanceMethodDeclaration;

        case CXCursor_ObjCClassMethodDecl:
            return PLClangCursorKindObjCClassMethodDeclaration;

        case CXCursor_ObjCImplementationDecl:
            return PLClangCursorKindObjCImplementationDeclaration;

        case CXCursor_ObjCCategoryImplDecl:
            return PLClangCursorKindObjCCategoryImplementationDeclaration;

        case CXCursor_TypedefDecl:
            return PLClangCursorKindTypedefDeclaration;

        case CXCursor_CXXMethod:
            return PLClangCursorKindCXXMethod;

        case CXCursor_Namespace:
            return PLClangCursorKindNamespace;

        case CXCursor_LinkageSpec:
            return PLClangCursorKindLinkageSpecification;

        case CXCursor_Constructor:
            return PLClangCursorKindConstructor;

        case CXCursor_Destructor:
            return PLClangCursorKindDestructor;

        case CXCursor_ConversionFunction:
            return PLClangCursorKindConversionFunction;

        case CXCursor_TemplateTypeParameter:
            return PLClangCursorKindTemplateTypeParameter;

        case CXCursor_NonTypeTemplateParameter:
            return PLClangCursorKindNonTypeTemplateParameter;

        case CXCursor_TemplateTemplateParameter:
            return PLClangCursorKindTemplateTemplateParameter;

        case CXCursor_FunctionTemplate:
            return PLClangCursorKindFunctionTemplate;

        case CXCursor_ClassTemplate:
            return PLClangCursorKindClassTemplate;

        case CXCursor_ClassTemplatePartialSpecialization:
            return PLClangCursorKindClassTemplatePartialSpecialization;

        case CXCursor_NamespaceAlias:
            return PLClangCursorKindNamespaceAlias;

        case CXCursor_UsingDirective:
            return PLClangCursorKindUsingDirective;

        case CXCursor_UsingDeclaration:
            return PLClangCursorKindUsingDeclaration;

        case CXCursor_TypeAliasDecl:
            return PLClangCursorKindTypeAliasDeclaration;

        case CXCursor_ObjCSynthesizeDecl:
            return PLClangCursorKindObjCSynthesizeDeclaration;

        case CXCursor_ObjCDynamicDecl:
            return PLClangCursorKindObjCDynamicDeclaration;

        case CXCursor_CXXAccessSpecifier:
            return PLClangCursorKindCXXAccessSpecifier;

        case CXCursor_ObjCSuperClassRef:
            return PLClangCursorKindObjCSuperclassReference;

        case CXCursor_ObjCProtocolRef:
            return PLClangCursorKindObjCProtocolReference;

        case CXCursor_ObjCClassRef:
            return PLClangCursorKindObjCClassReference;

        case CXCursor_TypeRef:
            return PLClangCursorKindTypeReference;

        case CXCursor_CXXBaseSpecifier:
            return PLClangCursorKindCXXBaseSpecifier;

        case CXCursor_TemplateRef:
            return PLClangCursorKindTemplateReference;

        case CXCursor_NamespaceRef:
            return PLClangCursorKindNamespaceReference;

        case CXCursor_MemberRef:
            return PLClangCursorKindMemberReference;

        case CXCursor_LabelRef:
            return PLClangCursorKindLabelReference;

        case CXCursor_OverloadedDeclRef:
            return PLClangCursorKindOverloadedDeclarationReference;

        case CXCursor_VariableRef:
            return PLClangCursorKindVariableReference;

        case CXCursor_UnexposedExpr:
            return PLClangCursorKindUnexposedExpression;

        case CXCursor_DeclRefExpr:
            return PLClangCursorKindDeclarationReferenceExpression;

        case CXCursor_MemberRefExpr:
            return PLClangCursorKindMemberReferenceExpression;

        case CXCursor_CallExpr:
            return PLClangCursorKindCallExpression;

        case CXCursor_ObjCMessageExpr:
            return PLClangCursorKindObjCMessageExpression;

        case CXCursor_BlockExpr:
            return PLClangCursorKindBlockExpression;

        case CXCursor_IntegerLiteral:
            return PLClangCursorKindIntegerLiteral;

        case CXCursor_FloatingLiteral:
            return PLClangCursorKindFloatingLiteral;

        case CXCursor_ImaginaryLiteral:
            return PLClangCursorKindImaginaryLiteral;

        case CXCursor_StringLiteral:
            return PLClangCursorKindStringLiteral;

        case CXCursor_CharacterLiteral:
            return PLClangCursorKindCharacterLiteral;

        case CXCursor_ParenExpr:
            return PLClangCursorKindParenthesizedExpression;

        case CXCursor_UnaryOperator:
            return PLClangCursorKindUnaryOperator;

        case CXCursor_ArraySubscriptExpr:
            return PLClangCursorKindArraySubscriptExpression;

        case CXCursor_BinaryOperator:
            return PLClangCursorKindBinaryOperator;

        case CXCursor_CompoundAssignOperator:
            return PLClangCursorKindCompoundAssignmentOperator;

        case CXCursor_ConditionalOperator:
            return PLClangCursorKindConditionalOperator;

        case CXCursor_CStyleCastExpr:
            return PLClangCursorKindCStyleCastExpression;

        case CXCursor_CompoundLiteralExpr:
            return PLClangCursorKindCompoundLiteralExpression;

        case CXCursor_InitListExpr:
            return PLClangCursorKindInitializerListExpression;

        case CXCursor_AddrLabelExpr:
            return PLClangCursorKindAddressLabelExpression;

        case CXCursor_StmtExpr:
            return PLClangCursorKindStatementExpression;

        case CXCursor_GenericSelectionExpr:
            return PLClangCursorKindGenericSelectionExpression;

        case CXCursor_GNUNullExpr:
            return PLClangCursorKindGNUNullExpression;

        case CXCursor_CXXStaticCastExpr:
            return PLClangCursorKindCXXStaticCastExpression;

        case CXCursor_CXXDynamicCastExpr:
            return PLClangCursorKindCXXDynamicCastExpression;

        case CXCursor_CXXReinterpretCastExpr:
            return PLClangCursorKindCXXReinterpretCastExpression;

        case CXCursor_CXXConstCastExpr:
            return PLClangCursorKindCXXConstCastExpression;

        case CXCursor_CXXFunctionalCastExpr:
            return PLClangCursorKindCXXFunctionalCastExpression;

        case CXCursor_CXXTypeidExpr:
            return PLClangCursorKindCXXTypeidExpression;

        case CXCursor_CXXBoolLiteralExpr:
            return PLClangCursorKindCXXBoolLiteralExpression;

        case CXCursor_CXXNullPtrLiteralExpr:
            return PLClangCursorKindCXXNullPtrLiteralExpression;

        case CXCursor_CXXThisExpr:
            return PLClangCursorKindCXXThisExpression;

        case CXCursor_CXXThrowExpr:
            return PLClangCursorKindCXXThrowExpression;

        case CXCursor_CXXNewExpr:
            return PLClangCursorKindCXXNewExpression;

        case CXCursor_CXXDeleteExpr:
            return PLClangCursorKindCXXDeleteExpression;

        case CXCursor_UnaryExpr:
            return PLClangCursorKindUnaryExpression;

        case CXCursor_ObjCStringLiteral:
            return PLClangCursorKindObjCStringLiteral;

        case CXCursor_ObjCEncodeExpr:
            return PLClangCursorKindObjCEncodeExpression;

        case CXCursor_ObjCSelectorExpr:
            return PLClangCursorKindObjCSelectorExpression;

        case CXCursor_ObjCProtocolExpr:
            return PLClangCursorKindObjCProtocolExpression;

        case CXCursor_ObjCBridgedCastExpr:
            return PLClangCursorKindObjCBridgedCastExpression;

        case CXCursor_PackExpansionExpr:
            return PLClangCursorKindPackExpansionExpression;

        case CXCursor_SizeOfPackExpr:
            return PLClangCursorKindSizeOfPackExpression;

        case CXCursor_LambdaExpr:
            return PLClangCursorKindLambdaExpression;

        case CXCursor_ObjCBoolLiteralExpr:
            return PLClangCursorKindLambdaExpression;

        case CXCursor_ObjCSelfExpr:
            return PLClangCursorKindObjCSelfExpression;

        case CXCursor_UnexposedStmt:
            return PLClangCursorKindUnexposedStatement;

        case CXCursor_LabelStmt:
            return PLClangCursorKindLabelStatement;

        case CXCursor_CompoundStmt:
            return PLClangCursorKindCompoundStatement;

        case CXCursor_CaseStmt:
            return PLClangCursorKindCaseStatement;

        case CXCursor_DefaultStmt:
            return PLClangCursorKindDefaultStatement;

        case CXCursor_IfStmt:
            return PLClangCursorKindIfStatement;

        case CXCursor_SwitchStmt:
            return PLClangCursorKindSwitchStatement;

        case CXCursor_WhileStmt:
            return PLClangCursorKindWhileStatement;

        case CXCursor_DoStmt:
            return PLClangCursorKindDoStatement;

        case CXCursor_ForStmt:
            return PLClangCursorKindForStatement;

        case CXCursor_GotoStmt:
            return PLClangCursorKindGotoStatement;

        case CXCursor_IndirectGotoStmt:
            return PLClangCursorKindIndirectGotoStatement;

        case CXCursor_ContinueStmt:
            return PLClangCursorKindContinueStatement;

        case CXCursor_BreakStmt:
            return PLClangCursorKindBreakStatement;

        case CXCursor_ReturnStmt:
            return PLClangCursorKindReturnStatement;

        case CXCursor_AsmStmt:
            return PLClangCursorKindAsmStatement;

        case CXCursor_ObjCAtTryStmt:
            return PLClangCursorKindObjCAtTryStatement;

        case CXCursor_ObjCAtCatchStmt:
            return PLClangCursorKindObjCAtCatchStatement;

        case CXCursor_ObjCAtFinallyStmt:
            return PLClangCursorKindObjCAtFinallyStatement;

        case CXCursor_ObjCAtThrowStmt:
            return PLClangCursorKindObjCAtThrowStatement;

        case CXCursor_ObjCAtSynchronizedStmt:
            return PLClangCursorKindObjCAtSynchronizedStatement;

        case CXCursor_ObjCAutoreleasePoolStmt:
            return PLClangCursorKindObjCAutoreleasePoolStatement;

        case CXCursor_ObjCForCollectionStmt:
            return PLClangCursorKindObjCForCollectionStatement;

        case CXCursor_CXXCatchStmt:
            return PLClangCursorKindCXXCatchStatement;

        case CXCursor_CXXTryStmt:
            return PLClangCursorKindCXXTryStatement;

        case CXCursor_CXXForRangeStmt:
            return PLClangCursorKindCXXForRangeStatement;

        case CXCursor_SEHTryStmt:
            return PLClangCursorKindSEHTryStatement;

        case CXCursor_SEHExceptStmt:
            return PLClangCursorKindSEHExceptStatement;

        case CXCursor_SEHFinallyStmt:
            return PLClangCursorKindSEHFinallyStatement;

        case CXCursor_MSAsmStmt:
            return PLClangCursorKindMSAsmStatement;

        case CXCursor_NullStmt:
            return PLClangCursorKindNullStatement;

        case CXCursor_DeclStmt:
            return PLClangCursorKindDeclarationStatement;

        case CXCursor_OMPParallelDirective:
            return PLClangCursorKindOMPParallelDirective;

        case CXCursor_TranslationUnit:
            return PLClangCursorKindTranslationUnit;

        case CXCursor_UnexposedAttr:
            return PLClangCursorKindUnexposedAttribute;

        case CXCursor_IBActionAttr:
            return PLClangCursorKindIBActionAttribute;

        case CXCursor_IBOutletAttr:
            return PLClangCursorKindIBOutletAttribute;

        case CXCursor_IBOutletCollectionAttr:
            return PLClangCursorKindIBOutletCollectionAttribute;

        case CXCursor_CXXFinalAttr:
            return PLClangCursorKindCXXFinalAttribute;

        case CXCursor_CXXOverrideAttr:
            return PLClangCursorKindCXXOverrideAttribute;

        case CXCursor_AnnotateAttr:
            return PLClangCursorKindAnnotateAttribute;

        case CXCursor_AsmLabelAttr:
            return PLClangCursorKindAsmLabelAttribute;

        case CXCursor_PreprocessingDirective:
            return PLClangCursorKindPreprocessingDirective;

        case CXCursor_MacroDefinition:
            return PLClangCursorKindMacroDefinition;

        case CXCursor_MacroExpansion:
            return PLClangCursorKindMacroExpansion;

        case CXCursor_InclusionDirective:
            return PLClangCursorKindInclusionDirective;

        case CXCursor_ModuleImportDecl:
            return PLClangCursorKindModuleImportDeclaration;

        case CXCursor_InvalidFile:
        case CXCursor_NoDeclFound:
        case CXCursor_NotImplemented:
        case CXCursor_InvalidCode:
            // Unreachable, invalid cursors return nil from initWithCXCursor:
            break;
    }

    // Cursor has an unknown kind
    abort();
}

/**
 * The language of the entity the cursor refers to.
 */
- (PLClangLanguage) language {
    switch (clang_getCursorLanguage(_cursor)) {
        case CXLanguage_Invalid:
            return PLClangLanguageInvalid;

        case CXLanguage_C:
            return PLClangLanguageC;

        case CXLanguage_CPlusPlus:
            return PLClangLanguageCPlusPlus;

        case CXLanguage_ObjC:
            return PLClangLanguageObjC;
    }

    // Cursor is in an unknown language
    abort();
}

/**
 * The linkage of the entity the cursor refers to.
 */
- (PLClangLinkage) linkage {
    switch (clang_getCursorLinkage(_cursor)) {
        case CXLinkage_Invalid:
            return PLClangLinkageInvalid;

        case CXLinkage_NoLinkage:
            return PLClangLinkageNone;

        case CXLinkage_Internal:
            return PLClangLinkageInternal;

        case CXLinkage_UniqueExternal:
            return PLClangLinkageUniqueExternal;

        case CXLinkage_External:
            return PLClangLinkageExternal;
    }

    // Cursor has unknown linkage
    abort();
}

/**
 * A Boolean value indicating whether the cursor represents an attribute.
 */
- (BOOL) isAttribute {
    return clang_isAttribute(_cursor.kind);
}

/**
 * A Boolean value indicating whether the cursor represents a declaration.
 */
- (BOOL) isDeclaration {
    return clang_isDeclaration(_cursor.kind);
}

/**
 * A Boolean value indicating whether the cursor represents an expression.
 */
- (BOOL) isExpression {
    return clang_isExpression(_cursor.kind);
}

/**
 * A Boolean value indicating whether the cursor represents a preprocessing
 * element, such as a preprocessor directive or macro expansion.
 */
- (BOOL) isPreprocessing {
    return clang_isPreprocessing(_cursor.kind);
}

/**
 * A Boolean value indicating whether the cursor represents a simple reference.
 */
- (BOOL) isReference {
    return clang_isReference(_cursor.kind);
}

/**
 * A Boolean value indicating whether the cursor represents a statement.
 */
- (BOOL) isStatement {
    return clang_isStatement(_cursor.kind);
}

/**
 * A Boolean value indicating whether the cursor represents an unexposed piece of the AST.
 */
- (BOOL) isUnexposed {
    return clang_isUnexposed(_cursor.kind);
}

/**
 * A Boolean value indicating whether the cursor represents an Objective-C method
 * or property declaration that was affected by \@optional.
 */
- (BOOL) isObjCOptional {
    return clang_Cursor_isObjCOptional(_cursor);
}

/**
 * A Boolean value indicating whether the cursor represents a variadic function or method.
 */
- (BOOL) isVariadic {
    return clang_Cursor_isVariadic(_cursor);
}

/**
 * The canonical cursor corresponding to this cursor.
 *
 * In the C family of languages, many kinds of entities can be declared several
 * times within a single translation unit. For example, a structure type can
 * be forward-declared (possibly multiple times) and later defined:
 *
 * @code
 * struct X;
 * struct X;
 * struct X {
 *   int member;
 * };
 * @endcode
 *
 * The declarations and the definition of \c X are represented by three
 * different cursors, all of which are declarations of the same underlying
 * entity. One of these cursor is considered the "canonical" cursor, which
 * is effectively the representative for the underlying entity. One can
 * determine if two cursors are declarations of the same underlying entity by
 * comparing their canonical cursors.
 */
- (PLClangCursor *) canonicalCursor {
    return _canonicalCursor ?: (_canonicalCursor = [[PLClangCursor alloc] initWithCXCursor: clang_getCanonicalCursor(_cursor)]);
}

/**
 * The semantic parent of this cursor.
 *
 * The semantic parent of a cursor is the cursor that semantically contains
 * this cursor. For many declarations, the lexical and semantic parents
 * are equivalent. They diverge when declarations or definitions are provided out-of-line.
 * For example:
 *
 * @code
 * class C {
 *  void f();
 * };
 *
 * void C::f() { }
 * @endcode
 *
 * In the out-of-line definition of @c C::f, the semantic parent is the
 * the class @c C, of which this function is a member. The lexical parent is
 * the place where the declaration actually occurs in the source code; in this
 * case, the definition occurs in the translation unit. In general, the
 * lexical parent for a given entity can change without affecting the semantics
 * of the program, and the lexical parent of different declarations of the
 * same entity may be different. Changing the semantic parent of a declaration,
 * on the other hand, can have a major impact on semantics, and redeclarations
 * of a particular entity should all have the same semantic context.
 *
 * In the example above, both declarations of @c C::f have @c C as their
 * semantic context, while the lexical context of the first @c C::f is @c C
 * and the lexical context of the second @c C::f is the translation unit.
 *
 * For global declarations the semantic parent is the translation unit.
 */
- (PLClangCursor *) semanticParent {
    return _semanticParent ?: (_semanticParent = [[PLClangCursor alloc] initWithCXCursor: clang_getCursorSemanticParent(_cursor)]);
}

/**
 * The lexical parent of this cursor.
 *
 * The lexical parent of a cursor is the cursor in which this cursor
 * was actually written. For many declarations, the lexical and semantic parents
 * are equivalent. They diverge when declarations or definitions are provided out-of-line.
 * @sa semanticParent
 */
- (PLClangCursor *) lexicalParent {
    return _lexicalParent ?: (_lexicalParent = [[PLClangCursor alloc] initWithCXCursor: clang_getCursorLexicalParent(_cursor)]);
}

/**
 * For a cursor that is a reference, the cursor representing the entity that it references.
 *
 * Reference cursors refer to other entities in the AST. For example, an
 * Objective-C superclass reference cursor refers to an Objective-C class. If this cursor
 * represents the superclass reference then the value of this property is the cursor
 * representing that Objective-C class. If this cursor is a declaration or definition, then
 * the value of this property is a cursor representing that same declaration or definition.
 * For other cursor types the value of this property is nil.
 */
- (PLClangCursor *) referencedCursor {
    return _referencedCursor ?: (_referencedCursor = [[PLClangCursor alloc] initWithCXCursor: clang_getCursorReferenced(_cursor)]);
}

/**
 * For a cursor that is either a reference to or a declaration
 * of some entity, the cursor that describes the definition of
 * that entity.
 *
 * Some entities can be declared multiple times within a translation
 * unit, but only one of those declarations can also be a
 * definition. For example, given:
 *
 * @code
 * int f(int, int);
 * int g(int x, int y) { return f(x, y); }
 * int f(int a, int b) { return a + b; }
 * int f(int, int);
 * @endcode
 *
 * There are three declarations of the function "f", but only the
 * second one is a definition. If this cursor represents any declaration
 * of "f" (the first or fourth lines of the example) or a cursor referenced
 * that uses "f" (the call to "f' inside "g") the value of this property will
 * be a declaration cursor pointing to the definition (the second "f"
 * declaration).
 *
 * If this cursor has not corresponding definition, e.g., because there is no
 * definition of that entity within this translation unit, the value of this
 * property is nil.
 */
- (PLClangCursor *) definition {
    return _definition ?: (_definition = [[PLClangCursor alloc] initWithCXCursor: clang_getCursorDefinition(_cursor)]);
}

/**
 * The bit width of a bit field declaration as an integer.
 *
 * The value of this property is -1 if the cursor is not a bit field declaration.
 */
- (int) fieldDeclarationBitWidth {
    return clang_getFieldDeclBitWidth(_cursor);
}

/**
 * The attributes for an Objective-C property declaration.
 */
- (PLClangObjCPropertyAttributes) objCPropertyAttributes {
    PLClangObjCPropertyAttributes attrs = 0;
    unsigned int clangAttributes = clang_Cursor_getObjCPropertyAttributes(_cursor, 0);

    if (clangAttributes & CXObjCPropertyAttr_readonly)
        attrs |= PLClangObjCPropertyAttributeReadOnly;

    if (clangAttributes & CXObjCPropertyAttr_getter)
        attrs |= PLClangObjCPropertyAttributeGetter;

    if (clangAttributes & CXObjCPropertyAttr_assign)
        attrs |= PLClangObjCPropertyAttributeAssign;

    if (clangAttributes & CXObjCPropertyAttr_readwrite)
        attrs |= PLClangObjCPropertyAttributeReadWrite;

    if (clangAttributes & CXObjCPropertyAttr_retain)
        attrs |= PLClangObjCPropertyAttributeRetain;

    if (clangAttributes & CXObjCPropertyAttr_copy)
        attrs |= PLClangObjCPropertyAttributeCopy;

    if (clangAttributes & CXObjCPropertyAttr_nonatomic)
        attrs |= PLClangObjCPropertyAttributeNonAtomic;

    if (clangAttributes & CXObjCPropertyAttr_setter)
        attrs |= PLClangObjCPropertyAttributeSetter;

    if (clangAttributes & CXObjCPropertyAttr_atomic)
        attrs |= PLClangObjCPropertyAttributeAtomic;

    if (clangAttributes & CXObjCPropertyAttr_weak)
        attrs |= PLClangObjCPropertyAttributeWeak;

    if (clangAttributes & CXObjCPropertyAttr_strong)
        attrs |= PLClangObjCPropertyAttributeStrong;

    if (clangAttributes & CXObjCPropertyAttr_unsafe_unretained)
        attrs |= PLClangObjCPropertyAttributeUnsafeUnretained;

    return attrs;
}

/**
 * The selector index of an Objective-C method or message expression.
 *
 * If this cursor does not represent a selector identifier the value of this property is -1.
 */
- (int) objCSelectorIndex {
    return clang_Cursor_getObjCSelectorIndex(_cursor);
}

/**
 * The Objective-C type encoding for this cursor, or nil.
 */
- (NSString *) objCTypeEncoding {
    return plclang_convert_and_dispose_cxstring(clang_getDeclObjCTypeEncoding(_cursor));
}

/**
 * Recursively visit the children of this cursor.
 *
 * The traversal may be controlled by the PLClangCursorVisitResult returned from
 * each invocation of @a block.
 *
 * @param block The block invoked for each child visited.
 */
- (void) visitChildrenUsingBlock: (PLClangCursorVisitorBlock) block {
    clang_visitChildrenWithBlock(_cursor, ^enum CXChildVisitResult(CXCursor cursor, CXCursor parent) {
        PLClangCursor *child = [[PLClangCursor alloc] initWithCXCursor: cursor];

        switch (block(child)) {
            case PLClangCursorVisitBreak:
                return CXChildVisit_Break;

            case PLClangCursorVisitContinue:
                return CXChildVisit_Continue;

            case PLClangCursorVisitRecurse:
                return CXChildVisit_Recurse;
        }

        // The callee returned a value outside the range of PLClangCursorVisitResult
        abort();
    });
}

- (BOOL)isEqual: (id) object {
    if (![object isKindOfClass:[PLClangCursor class]])
        return NO;

    return clang_equalCursors(_cursor, [object cxCursor]);
}

- (NSUInteger) hash {
    return clang_hashCursor(_cursor);
}

- (NSString *) description {
    return self.spelling;
}

- (NSString *) debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> %@", [self class], self, [self description]];
}

@end

/**
 * @internal
 * Package-private methods.
 */
@implementation PLClangCursor (PackagePrivate)

/**
 * Initialize a newly-created cursor with the specified clang cursor.
 *
 * @param cursor The clang cursor that will back this cursor.
 * @return An initialized cursor or nil if the specified clang cursor was null or invalid.
 *
 * @internal
 * The related cursor objects are not created in the initializer because the related cursor
 * functions may return the same CXCursor. For example, the canonical cursor for the canonical
 * cursor is itself.
 */
- (instancetype) initWithCXCursor: (CXCursor) cursor {
    PLSuperInit();

    if (clang_Cursor_isNull(cursor) || clang_isInvalid(cursor.kind))
        return nil;

    _cursor = cursor;

    _USR = plclang_convert_and_dispose_cxstring(clang_getCursorUSR(_cursor));
    _spelling = plclang_convert_and_dispose_cxstring(clang_getCursorSpelling(_cursor));
    _displayName = plclang_convert_and_dispose_cxstring(clang_getCursorDisplayName(_cursor));

    int argCount = clang_Cursor_getNumArguments(_cursor);
    if (argCount >= 0) {
        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity: (unsigned int)argCount];

        for (unsigned int i = 0; i < (unsigned int)argCount; i++) {
            [arguments addObject: [[PLClangCursor alloc] initWithCXCursor: clang_Cursor_getArgument(_cursor, i)]];
        }

        _arguments = arguments;
    }

    if (cursor.kind == CXCursor_OverloadedDeclRef) {
        unsigned int count = clang_getNumOverloadedDecls(_cursor);
        NSMutableArray *declarations = [NSMutableArray arrayWithCapacity: count];

        for (unsigned int i = 0; i < count; i++) {
            [declarations addObject: [[PLClangCursor alloc] initWithCXCursor: clang_getOverloadedDecl(_cursor, i)]];
        }

        _overloadedDeclarations = declarations;
    }

    return self;
}

- (CXCursor) cxCursor {
    return _cursor;
}

@end
