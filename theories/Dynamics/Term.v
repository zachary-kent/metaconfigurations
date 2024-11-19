From Metaconfigurations Require Import Syntax.Term Syntax.Ty Syntax.Value Object Process.
From stdpp Require Import base.

Reserved Notation "⟨ ϵ, σ, e ⟩ ⇓ v" (at level 80, no associativity).

Section Eval.

  Variable Π : Type.

  Context `{Process Π}.

  Variable Ω : Type.

  Context `{Object Π Ω}.

  Variable π : Π.

  Inductive eval : Term.t Π Ω π → Value.t → Prop :=
    | 