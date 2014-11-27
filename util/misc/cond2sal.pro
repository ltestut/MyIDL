Function cond2sal, twat, bot
;;;Cond2Sal78 (aConductivity, Temp, Press : Double; Var aSalinity: Double) : Boolean;
;// Function Cond2Sal converts a conductivity value of seawater to a value
;// of the pratical-salinity-scale 1978 (PSS-78) for given values of
;// conductivity, temperature and pressure. Result is returned as
;// parameter in aSalinity. A returned boolean result TRUE of the
;// function indicates that the result is reliable.
;// UNITS:
;//   PRESSURE      Press          DECIBARS
;//   TEMPERATURE   Temp           DEG CELSIUS IPTS-68
;//   CONDUCTIVITY  aConductivity  S/m
;//   SALINITY      aSalinity      PSS-78
;// ----------------------------------------------------------
;// CHECKVALUES:
;//   2.) aSalinity=40.00000 for CND=1.888091, T=40 DEG C, P=10000 DECIBARS
;// ----------------------------------------------------------
;// SAL78 RATIO: RETURNS ZERO FOR CONDUCTIVITY RATIO: < 0.0005
;// ----------------------------------------------------------
;// This source code is based on the original fortran code in:
;//   UNESCO technical papers in marine science 44 (1983) -
;//   'Algorithms for computation of fundamental properties of seawater'
;// ----------------------------------------------------------
;// Written in object pascal by:
;//   Dr. Jan Schulz, 26. May 2008, www.code10.info

Function SAL (XR, XT: Double): Double;

    // PRACTICAL SALINITY SCALE 1978 DEFINITION WITH TEMPERATURE
    // CORRECTION;XT :=T-15.0; XR:=SQRT(RT);
    Begin

      SAL := ((((2.7081*XR-7.0261)*XR+14.0941)*XR+25.3851)*XR
              - 0.1692)*XR+0.0080
              + (XT/(1.0+0.0162*XT))*(((((-0.0144*XR
              + 0.0636)*XR-0.0375)*XR-0.0066)*XR-0.0056)*XR+0.0005);
    end;

    Function RT35 (XT : Double) : Double;
    // FUNCTION RT35: C(35,T,0)/C(35,15,0) VARIATION WITH TEMPERATURE
    Begin
      RT35 := (((1.0031E-9 * XT - 6.9698E-7) * XT + 1.104259E-4) * XT
               + 2.00564E-2) * XT + 0.6766097;
    end;

    Function C (XP : Double) : Double;
    // C(XP) POLYNOMIAL CORRESPONDS TO A1-A3 CONSTANTS: LEWIS 1980
    Begin
      C := ((3.989E-15 * XP - 6.370E-10) * XP + 2.070E-5) * XP;
    end;


    Function B (XT :Double) : Double;
    Begin
      B := (4.464E-4 * XT + 3.426E-2) * XT + 1.0;
    end;

    Function A (XT : Double): Double;
    //A(XT) POLYNOMIAL CORRESPONDS TO B3 AND B4 CONSTANTS: LEWIS 1980
    Begin
      A := -3.107E-3 * XT + 0.4215;
    end;
Var DT : Double;
    RT : Double;
Begin
// we expect the best
  Cond2Sal78 := True;
  aSalinity  := 0;

  // equation is not defined for conductivity values below 5e-4
  If aConductivity <= 0.2 THen
  Begin
    Cond2Sal78 := False;
    Exit;
  end;

  // start conversion
  DT        := Temp - 15;
  aSalinity := aConductivity/4.2914;
  RT        := aSalinity / (RT35 (Temp) * (1.0 + C (Press) / (B (Temp) + A (Temp) * aSalinity)));
  RT        := Sqrt (Abs (RT));
  aSalinity := SAL (RT, DT);

  // control, whether result is in the validity range of PSS-78
  If (aSalinity < 2) Or (aSalinity > 42) THen
  Begin
    Cond2Sal78 := False;
  end;
end;
END
;Version de Philppe
;      subroutine scient_conduc2sal(pres,temp,cond,sal)
!     ------------------------------------------------

! calcul de la salinite de l'eau de mer (en psu) en fonction de la
! conductivite (en mmho/cm), de la pression (en dbars) et de la temperature
! (en degres C)
! creation Philippe Techine (version 0.0 - octobre 1999)
! a partir de sal81 cree par Gilles Reverdin (octobre 1979)
! et d'apres Unesco technical papers in marine science 44, Algorithms for
! computation of fundamental properties of seawater, Unesco 1983

      implicit none

! variables entree
      real*8 pres,temp,cond

! variable sortie
      real*8 sal

! variables locales
      real*8 r,rt35,a,b,c,rt,dt

! calcul du rapport de conductivite
      r=cond/42.909d0

! equation (3) fonction de la temperature
! valable dans la gamme -2 a +35 degres C
      rt35=(((1.0031d-9*temp - 6.9698d-7)*temp + 1.104259d-4)*temp
     -    + 2.00564d-2)*temp + 0.6766097d0

! equation (4) fonction de la pression et de la temperature
      c=((3.989d-15*pres - 6.370d-10)*pres + 2.070d-5)*pres
      b=(4.464d-4*temp + 3.426d-2)*temp + 1.d0
      a=-3.107d-3*temp + 0.4215d0
      rt=r/(rt35*(1.d0 + c/(b + a*r)))

! test si la valeur trouvee est negative pour les equations (1) et (2)
      if (rt.lt.0.) rt=0.d0
      rt=sqrt(rt)

! calcul intermediaire pour l'equation (2)
      dt=temp-15.d0

! equations (1) et (2) valables dans les gammes de temperture -2 a +35 degres C
!                                            et de salinite 2 a 42 psu
      sal=((((2.7081d0*rt - 7.0261d0)*rt + 14.0941d0)*rt + 25.3851d0)*rt
     -   - 0.1692d0)*rt + 0.0080d0
     -   +(((((-0.0144d0*rt + 0.0636d0)*rt - 0.0375d0)*rt - 0.0066d0)*rt
     -   - 0.0056d0)*rt + 0.0005d0) * (dt/(1.d0 + 0.0162d0*dt))
      end
