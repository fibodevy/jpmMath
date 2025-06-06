{*************************************************************************
*  Solve a first order DE system (N=2) of the form:                      *
*  y' = F(x,y,z), z'=G(x,y,z) with conditions: y(x0)=a and z(x0)=b from  *
*  x=x0 to x=x1 using a Runge-Kutta integration method.                  *
* ---------------------------------------------------------------------- *
* SAMPLE RUN:                                                            *
*      Integrate first order DE systemy:                                 *
*          y' = y*z + cos(x) - 0.5*sin(2*x)                              *
*          z' = y*y + z*z - (1 + sin(x))                                 *
*      from x=0 to x=2 with initial conditions: y(0)=0 and z(0)=0        *
*           (25 integration steps).                                      *
*                                                                        *
*     X     Y estimated  Z estimated                                     *
* ------------------------------------                                   *
*   0.0000   0.0000000    0.0000000                                      *
*   0.0800   0.0765518   -0.0828580                                      *
*   0.1600   0.1452904   -0.1700792                                      *
*   0.2400   0.2050556   -0.2597237                                      *
*   0.3200   0.2550329   -0.3500533                                      *
*   0.4000   0.2948004   -0.4396008                                      *
*   0.4800   0.3243379   -0.5271915                                      *
*   0.5600   0.3440043   -0.6119278                                      *
*   0.6400   0.3544874   -0.6931461                                      *
*   0.7200   0.3567373   -0.7703644                                      *
*   0.8000   0.3518908   -0.8432315                                      *
*   0.8800   0.3411943   -0.9114874                                      *
*   0.9600   0.3259299   -0.9749377                                      *
*   1.0400   0.3073506   -1.0334409                                      *
*   1.1200   0.2866242   -1.0869048                                      *
*   1.2000   0.2647908   -1.1352886                                      *
*   1.2800   0.2427308   -1.1786041                                      *
*   1.3600   0.2211465   -1.2169165                                      *
*   1.4400   0.2005537   -1.2503410                                      *
*   1.5200   0.1812830   -1.2790362                                      *
*   1.6000   0.1634888   -1.3031952                                      *
*   1.6800   0.1471644   -1.3230351                                      *
*   1.7600   0.1321612   -1.3387869                                      *
*   1.8400   0.1182104   -1.3506867                                      *
*   1.9200   0.1049465   -1.3589674                                      *
*   2.0000   0.0919314   -1.3638530                                      *
*                                                                        *
* ---------------------------------------------------------------------- *
* REFERENCE: "Méthode de calcul numérique- Tome 2 - Programmes en Basic  *
*             et en Pascal By Claude Nowakowski, Edition du P.S.I., 1984"*
*             [BIBLI 04].                                                *
*                                                                        *
*                                    TPW Release By J-P Moreau, Paris.   *
*                                            (www.jpmoreau.fr)           *
*************************************************************************}
Program Test_Rk4;
Uses WinCrt1;

Const SIZE = 100;

Type
      pVec = ^VEC;
      VEC = Array[0..SIZE] of Double;

Var   X,Y,Z: pVec;
      xl,x0,h: Double;
      k,kl,l: Integer;

      {y'=yz + cos(x) - 0.5sin(2x) }
      Function F(x,y,z:Double): Double;
      Begin
        F:=y*z + cos(x) - 0.5*sin(2*x)
      End;

      {z'=yy + zz -(1+sin(x)) }
      Function G(x,y,z:Double): Double;
      Begin
        G:=y*y + z*z -(1.0+sin(x))
      End;

      {Integrate sytem from x to x+h using Runge-Kutta}
      Procedure RK4(x,y,z,h:Double; var x1,y1,z1:Double);
      Var c1,c2,c3,c4,d1,d2,d3,d4,h2: Double;
      Begin
        c1:=F(x,y,z);
        d1:=G(x,y,z);
        h2:=h/2.0;
        c2:=F(x+h2,y+h2*c1,z+h2*d1);
        d2:=G(x+h2,y+h2*c1,z+h2*d1);
        c3:=F(x+h2,y+h2*c2,z+h2*d2);
        d3:=G(x+h2,y+h2*c2,z+h2*d2);
        c4:=F(x+h,y+h*c3,z+h*d3);
        d4:=G(x+h,y+h*c3,z+h*d3);
        x1:=x+h;
        y1:=y+h*(c1+2.0*c2+2.0*c3+c4)/6.0;
        z1:=z+h*(d1+2.0*d2+2.0*d3+d4)/6.0
      End;

{main program}
BEGIN
  {allocate memory for X,Y,Z}
  New(X); New(Y); New(Z);
  x0:=0.0;       {starting x}
  xl:=2.0;       {ending x}
  kl:=25;        {number of steps in x}
  h:=(xl-x0)/kl; {integration step}
  X^[0]:=x0;
  Y^[0]:=0.0; Z^[0]:=0.0; {starting values}
  {integration loop}
  for k:=0 to kl-1 do
    RK4(X^[k],Y^[k],Z^[k],h,X^[k+1],Y^[k+1],Z^[k+1]);
  {write header}
  WriteLn;
  WriteLn('     X     Y estimated    Z estimated ');
  WriteLn(' -------------------------------------');
  {write kl+1 result lines}
  for k:=0 to kl do
    WriteLn(X^[k]:9:4,Y^[k]:12:7,'   ',Z^[k]:12:7);
  WriteLn(' -------------------------------------');
  ReadKey;
  {free memory and exit program}
  Dispose(X); Dispose(Y); Dispose(Z);
  DoneWinCrt

END.

{end of file trk4.pas}