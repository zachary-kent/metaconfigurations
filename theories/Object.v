From stdpp Require Import base gmap.
Require Import Coq.Sets.Ensembles.
Require Import Coq.Strings.String.
From Metaconfigurations.Syntax Require Import Value Ty.
From Metaconfigurations.Statics Require Import Value.

Record object_type (Π : Type) := {
  Σ : Type;
  OP : Type;
  (* OP : ARG OP → RES OP *)
  ARG : OP → Ty.t;
  RES : OP → Ty.t;
  δ : Σ → Π → ∀ op, V⟦ ARG op ⟧ → Σ * V⟦ RES op ⟧;
}.

Class Object (Π : Type) (Ω : Type) `{EqDecision Ω} := {
  type : Ω → object_type Π;
  (* state : ∀ (ω : Ω), (type ω).(Σ Π) *)
}.
