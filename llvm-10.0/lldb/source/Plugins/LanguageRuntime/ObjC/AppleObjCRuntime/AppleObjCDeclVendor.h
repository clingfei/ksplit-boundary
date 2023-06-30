//===-- AppleObjCDeclVendor.h -----------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef liblldb_AppleObjCDeclVendor_h_
#define liblldb_AppleObjCDeclVendor_h_

#include "lldb/Symbol/ClangASTContext.h"
#include "lldb/lldb-private.h"

#include "Plugins/ExpressionParser/Clang/ClangDeclVendor.h"
#include "Plugins/LanguageRuntime/ObjC/ObjCLanguageRuntime.h"

namespace lldb_private {

class AppleObjCExternalASTSource;

class AppleObjCDeclVendor : public ClangDeclVendor {
public:
  AppleObjCDeclVendor(ObjCLanguageRuntime &runtime);

  static bool classof(const DeclVendor *vendor) {
    return vendor->GetKind() == eAppleObjCDeclVendor;
  }

  uint32_t FindDecls(ConstString name, bool append, uint32_t max_matches,
                     std::vector<CompilerDecl> &decls) override;

  friend class AppleObjCExternalASTSource;

private:
  clang::ObjCInterfaceDecl *GetDeclForISA(ObjCLanguageRuntime::ObjCISA isa);
  bool FinishDecl(clang::ObjCInterfaceDecl *decl);

  ObjCLanguageRuntime &m_runtime;
  ClangASTContext m_ast_ctx;
  ObjCLanguageRuntime::EncodingToTypeSP m_type_realizer_sp;
  AppleObjCExternalASTSource *m_external_source;

  typedef llvm::DenseMap<ObjCLanguageRuntime::ObjCISA,
                         clang::ObjCInterfaceDecl *>
      ISAToInterfaceMap;

  ISAToInterfaceMap m_isa_to_interface;
};

} // namespace lldb_private

#endif // liblldb_AppleObjCDeclVendor_h_