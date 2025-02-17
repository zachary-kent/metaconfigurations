From Metaconfigurations Require Import 
  Map Syntax.Term Syntax.Value Object.
From stdpp Require Import base stringmap decidable.
Require Import Coq.Logic.FunctionalExtensionality.
Require Import Coq.Program.Equality.

Global Declare Scope dynamics_scope.

Definition states (Π Ω : Type) `{Object Π Ω} := Map.dependent Ω (Σ ∘ type).

Variant eval_binop : Term.bop → Value.t → Value.t → Value.t → Type :=
  | eval_add (n₁ n₂ : Z) : eval_binop Term.Add n₁ n₂ (n₁ + n₂)%Z
  | eval_sub (n₁ n₂ : Z) : eval_binop Term.Sub n₁ n₂ (n₁ - n₂)%Z
  | eval_mul (n₁ n₂ : Z) : eval_binop Term.Mul n₁ n₂ (n₁ * n₂)%Z
  | eval_or (b₁ b₂ : bool) : eval_binop Term.Or b₁ b₂ (b₁ || b₂)
  | eval_and (b₁ b₂ : bool) : eval_binop Term.And b₁ b₂ (b₁ && b₂).

Variant eval_unop : Term.uop → Value.t → Value.t → Type :=
  | eval_not (b : bool) : eval_unop Term.Not b (negb b).  

    (* match bop, v₁, v₂ with
    | Add, Value.Int n₁, Value.Int n₂ => (n₁ + n₂)%Z
    | Sub, Value.Int n₁, Value.Int n₂ => (n₁ - n₂)%Z
    | Mul, Value.Int n₁, Value.Int n₂ => (n₁ * n₂)%Z
    | 
    end. *)

(* (ω : Ω) (op : (type ω).(OP)) (arg : (type ω).(ARG Π) *)

Variant eval_inv {Π Ω} `{Object Π Ω} π ϵ ω op arg σ res :=
  | eval_inv_intro :
    (type ω).(δ) (Map.lookup ω ϵ) π op arg σ res →
    eval_inv π ϵ ω op arg σ res.

Reserved Notation "⟨ π , Ψ , ϵ , e ⟩ ⇓ₑ ⟨ ϵ' , v ⟩" (at level 80, no associativity).

Inductive eval {Π Ω} `{Object Π Ω} (π : Π) (ψ : stringmap Value.t) (ϵ : states Π Ω) : Term.t Π Ω → states Π Ω → Value.t → Prop := 
  | eval_var x v :
    ψ !! x = Some v →
    ⟨ π , ψ , ϵ , Var x ⟩ ⇓ₑ ⟨ ϵ , v ⟩
  | eval_invoke ω op arg argᵥ res ϵ' σ :
    ⟨ π , ψ , ϵ , arg ⟩ ⇓ₑ ⟨ ϵ' , argᵥ ⟩ →
    eval_inv π ϵ ω op argᵥ σ res →
    ⟨ π , ψ , ϵ , Invoke ω op arg ⟩ ⇓ₑ ⟨ rebind ω σ ϵ' , res ⟩
  | eval_bop bop e₁ e₂ v₁ v₂ v ϵ₁ ϵ₂ : 
    ⟨ π , ψ , ϵ , e₁ ⟩ ⇓ₑ ⟨ ϵ₁ , v₁ ⟩ →
    ⟨ π , ψ , ϵ₁ , e₂ ⟩ ⇓ₑ ⟨ ϵ₂ , v₂ ⟩ →
    eval_binop bop v₁ v₂ v →
    ⟨ π , ψ , ϵ , Bop bop e₁ e₂ ⟩ ⇓ₑ ⟨ ϵ₂ , v ⟩
  | eval_uop e uop ϵ' v v' :
    ⟨ π , ψ , ϵ , e ⟩ ⇓ₑ ⟨ ϵ' , v ⟩ →
    eval_unop uop v v' → 
    ⟨ π , ψ , ϵ , Uop uop e ⟩ ⇓ₑ ⟨ ϵ' , v' ⟩
  | eval_pair e₁ e₂ v₁ v₂ ϵ₁ ϵ₂ :
    ⟨ π , ψ , ϵ , e₁ ⟩ ⇓ₑ ⟨ ϵ₁ , v₁ ⟩ →
    ⟨ π , ψ , ϵ₁ , e₂ ⟩ ⇓ₑ ⟨ ϵ₂ , v₂ ⟩ →
    ⟨ π , ψ , ϵ , Term.Pair e₁ e₂ ⟩ ⇓ₑ ⟨ ϵ₂ , Pair v₁ v₂ ⟩
  | eval_projl e v₁ v₂ ϵ' :
    ⟨ π , ψ , ϵ , e ⟩ ⇓ₑ ⟨ ϵ' , Pair v₁ v₂ ⟩ →
    ⟨ π , ψ , ϵ , ProjL e ⟩ ⇓ₑ ⟨ ϵ' , v₁ ⟩
  | eval_projr e v₁ v₂ ϵ' :
    ⟨ π , ψ , ϵ , e ⟩ ⇓ₑ ⟨ ϵ' , Pair v₁ v₂ ⟩ →
    ⟨ π , ψ , ϵ , ProjR e ⟩ ⇓ₑ ⟨ ϵ' , v₂ ⟩
  | eval_int n :
    ⟨ π , ψ , ϵ , Term.Int n ⟩ ⇓ₑ ⟨ ϵ , n ⟩
  | eval_bool b :
    ⟨ π , ψ , ϵ , Term.Bool b ⟩ ⇓ₑ ⟨ ϵ , b ⟩
  | eval_unit :
    ⟨ π , ψ , ϵ , ⊤ₑ ⟩ ⇓ₑ ⟨ ϵ , ⊤ᵥ ⟩
where "⟨ π , ψ , ϵ , e ⟩ ⇓ₑ ⟨ ϵ' , v ⟩" := (eval π ψ ϵ e ϵ' v) : dynamics_scope.