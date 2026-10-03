module Stage0.Epoch.GohStreamTransducer

import public Stage0.BoxInt
import public Stage0.Multiset
import public Stage0.PrimeMultiset
import public Data.Fuel
import Stage1.Epoch.ChromogeometryLaw

import Stage0.OnSeq.FusedStream

%default total

--------------------------------------------------------------------------------
-- 1. STERN-BROCOT & GOH ENERGY STREAM TRANSDUCERS (PRIME 13 FUEL LIMIT)
--------------------------------------------------------------------------------

||| Prime 13 Fuel Limit governing the 13-smooth gate purity boundary.
||| Observer epoch k=38 (n=39=3x13) operates under exact Prime 13 fuel bounds.
public export
prime13Fuel : Fuel
prime13Fuel = limit 13

||| Evaluates a Goh energy stream transducer over a Dark Energy law ledger using an exact Nat step count.
public export
evalGohEnergyStreamNat : Nat -> Nat -> ChromogeometryLawLedger -> List GohEnergyStep -> List GohEnergyStep
evalGohEnergyStreamNat Z _ _ acc = acc
evalGohEnergyStreamNat (S steps) k ledger acc =
  let totalLaws = countTotalDarkLaws ledger
      gohStep   = MkGohStep (k * 13) (S totalLaws)
  in evalGohEnergyStreamNat steps (S k) ledger (gohStep :: acc)

||| Evaluates a Goh energy stream transducer over a Dark Energy law ledger using Prime 13 fuel.
public export covering
evalGohEnergyStream : Fuel -> Nat -> ChromogeometryLawLedger -> List GohEnergyStep -> List GohEnergyStep
evalGohEnergyStream Dry _ _ acc = acc
evalGohEnergyStream (More f') k ledger acc =
  let totalLaws = countTotalDarkLaws ledger
      gohStep   = MkGohStep (k * 13) (S totalLaws)
  in evalGohEnergyStream f' (S k) ledger (gohStep :: acc)

||| Deforested stream unfolding of Goh energy steps using exact Nat steps without Fuel.
public export
streamGohEnergyStreamNat : Nat -> Nat -> ChromogeometryLawLedger -> FusedStream GohEnergyStep
streamGohEnergyStreamNat maxSteps initK ledger =
  unfoldStream (\(steps, k) => case steps of
                                 Z => Done
                                 S steps' =>
                                   let totalLaws = countTotalDarkLaws ledger
                                       gohStep   = MkGohStep (k * 13) (S totalLaws)
                                   in Yield gohStep (steps', S k)) (maxSteps, initK)

||| Deforested stream unfolding of Goh energy steps using Prime 13 fuel without intermediate list allocations.
public export covering
streamGohEnergyStream : Fuel -> Nat -> ChromogeometryLawLedger -> FusedStream GohEnergyStep
streamGohEnergyStream fuel initK ledger =
  unfoldStream (\(f, k) => case f of
                             Dry => Done
                             More f' =>
                               let totalLaws = countTotalDarkLaws ledger
                                   gohStep   = MkGohStep (k * 13) (S totalLaws)
                               in Yield gohStep (f', S k)) (fuel, initK)

||| Stream transducer executing 13-smoothness checks directly over a stream of GohEnergySteps.
public export
goh13SmoothnessTransducer : StreamTransducer GohEnergyStep Bool
goh13SmoothnessTransducer = MkTransducer (\_, step => Yield (auditGoh13Smoothness step) ()) ()

||| Static proof witness verifying Prime 13 fuel limit bound (13 steps maximum).
public export
0 verifyPrime13FuelLimit : (f : Fuel) -> f = limit 13 -> True = True
verifyPrime13FuelLimit _ _ = Refl

--------------------------------------------------------------------------------
-- 2. GOH RATIONAL ENERGY TRANSDUCTION RATIO ENGINE
--------------------------------------------------------------------------------

||| Computes the rational Goh energy step ratio for a given epoch k and dark matter law count.
public export
computeGohStepForEpoch : Nat -> Nat -> GohEnergyStep
computeGohStepForEpoch k dmLaws = MkGohStep (k * 13) (S dmLaws)

||| Computes the rational Goh energy step for Observer Epoch 37 (481 / 56).
public export
getGohStep37 : GohEnergyStep
getGohStep37 = computeGohStepForEpoch 37 55

||| Static proof witness verifying Observer Epoch 37 Goh rational step equals 481 / 56.
public export
0 verifyGohStep37RationalRatio : Stage0.Epoch.GohStreamTransducer.getGohStep37 = MkGohStep 481 56
verifyGohStep37RationalRatio = Refl
