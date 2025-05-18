 {**************************************************************
 *     Linear Algebra Procedures used by program EF3D.pas      *
 **************************************************************}
 UNIT ALGEBLIN;

 INTERFACE
 Uses Declara1;   {General Types Declarations}

 PROCEDURE Transpose_Matrice_Carree(n:Integer; Var A:pMatc);
 PROCEDURE Matvec(n:Integer;
                  Var K: pMatc;
                  Var Ve,Vs: pVect;
                  option:integer);
 PROCEDURE Produit_Scalaire(n:Integer;
                            Var U,V: pVect;
                            Var result : arg_reel);
 PROCEDURE Multiplie_Matrix_3x3(Var A,B,C: Matrix_3x3);
 PROCEDURE Transpose_Matrix_3x3(Var A,ATr:Matrix_3x3);
 PROCEDURE Choldet1 (n:integer;
                     Var a:pMatc;
                     Var p:pVect;
                     Var d1:arg_reel;
                     Var d2:Integer;
                     Var Erreur:Boolean);
 PROCEDURE Cholsol1 (n,r    : integer;
                     Var a  : pMatc;
                     Var b,x: Matrice;
                     Var p  : pVect);
 PROCEDURE Tred2   (n:Integer;
                    tol:arg_reel;
                    Var a,z:pMatc;
                    Var d,e:pVect);
 PROCEDURE Tql2
                   (n:Integer;
                    macheps:arg_reel;
                    Var d,e:pVect;
                    Var z  :pMatc;
                    Var Erreur: Boolean);
 PROCEDURE Reduc1
                   (n:Integer;
                    var a,b:pMatc;
                    var dl:pVect;
                    var erreur: Boolean);
 PROCEDURE Rebaka  (n,m1,m2:Integer;
                    b:pMatc;
                    dl:pVect;
                    Var z: pMatc);


 IMPLEMENTATION

 {Transpose square matrix A}
 PROCEDURE Transpose_Matrice_Carree;
 Var i,j,iw,iwp1:integer;
     swap:arg_reel;
 BEGIN
   FOR iw:=1 to n do
   begin
     iwp1:=iw+1;
     FOR i:= iwp1 to n do
     begin
       swap:=A^[i][iw];
       A^[i][iw]:=A^[iw][i];
       A^[iw][i]:=swap;
     end;     (* i *)
   end;  (* iw *)
 END; (* Transpose *)


 PROCEDURE Matvec;
 {*********************************************************
 * Version 1.0, 30/8/1987                                 *
 * Calcule le produit d'une matrice carr�e par un vecteur *
 * colonne.                                               *
 * Calculate the product of a square matrix by a column   *
 * vector.                                                * 
 * Options:                                               *
 * option = 0  La matrice est enti�rement d�finie         *
 *             Matrix is entirely defined                 *
 *        = 1  La matrice,sym�trique, est d�finie par le  *
 *             triangle sup�rieur.                        *
 *             Only upper triangle is defined.            *
 *        =-1  La matrice est d�finie par le triangle in- *
 *             f�rieur.                                   *
 *             Only lower triangle is defined.            *
 *********************************************************}
 Var i,j    : Integer;
 begin
   For i:=1 to n do
   begin
     Vs^[i]:=0.;
     Case option of
     0:   For j:=1 to n do Vs^[i]:=Vs^[i]+K^[j][i]*Ve^[j];
     1:   begin
            For j:=1 to i-1 do Vs^[i]:=Vs^[i]+K^[i][j]*Ve^[j];
            For j:=i to n do Vs^[i]:=Vs^[i]+K^[j][i]*Ve^[j];
          end;
    -1:  begin
           For j:=1 to i do Vs^[i]:=Vs^[i]+K^[j][i]*Ve^[j];
           For j:=i+1 to n do Vs^[i]:=Vs^[i]+K^[i][j]*Ve^[j];
         end
     end  (* case *)
   end  (* i *)
 End;   (* MatVec *)

{*******************************************************
 Scalar Product }
 PROCEDURE Produit_Scalaire;
 Var i :integer;
 begin
   result:=0.;
   for i:=1 to n do result:=result+U^[i]*V^[i];
 End;   (* Produit_Scalaire *)

{*******************************************************
 3x3 matrix Multiplication }
 PROCEDURE Multiplie_Matrix_3x3;
 Var i,j,k :Integer;
 Begin
   For i:=1 to 3 do
   begin
     for j:= 1 to 3 do
     begin
       C[i,j]:=0;
       for k:=1 to 3 do C[i,j]:=C[i,j]+A[i,k]*B[k,j];
     end;
   end;
 End;
{*********************************************************
 Transpose 3x3 matrix }
 PROCEDURE Transpose_Matrix_3x3(Var A,ATr:Matrix_3x3);
 Var i,j :Integer;
 Begin
   For i:=1 to 3 do
     For j:=1 to 3 do
       ATr[i,j]:=A[j,i];
 End;

 {*******************************************************************
 * Cholesky.Inc - Version 1.0 du 23/10/1987 - J.P.DUMONT            *
 * Ref: Handbook for automatic computation Volume II Linear Algebra *
 *      J.H. Wilkinson et C.Reinsch, Springer Verlag, 1971          *
 ********************************************************************
 * D�composition d'une matrice sym�trique d�finie positive          *
 * Th�or�me de Cholesky: Si A est une matrice sym�trique d�finie po-*
 * sitive, alors il existe une matrice L triangulaire inf�rieure non*
 * singuli�re, telle que L Lt = A.                                  *
 *                                                                  *
 * Cholesky decomposition of a symmetric positive definite matrix   *
 *******************************************************************}
 PROCEDURE Choldet1;
 Label L1,L2;
 Var i,j,k  : Integer;
     x      : arg_reel;
 BEGIN
   erreur:=false;
   d1:=1;
   d2:=0;
   For i:=1 to n do
     For j:=1 to n do
     begin
       x:=a^[i][j];
       For k:=i-1 downto 1 do x:=x-a^[j][k]*a^[i][k];
       if (j=i) then
       begin
       d1:=d1*x;
       if (x=0) then
       begin
         d2:=0;
         erreur:=true;
         exit;
       end;
       L1: if abs(d1)>=1 then
           begin
           d1:=d1*0.0625;
           d2:=d2+4;
           goto L1;
           end;
       L2: if abs(d1)<0.0625 then
           begin
           d1:=d1*16;
           d2:=d2-4;
           goto L2;
           end;
           if x<0 then
              begin
              erreur:=true;
              exit;
              end;
           p^[i]:=1/sqrt(x);
       end
       else
         a^[j][i]:=x*p^[i];
     end; (* j *)
 END; (* Choldet1 *)
{**************************************************************
*   Solve a linear system by Cholesky decomposition method    *
**************************************************************}
 PROCEDURE Cholsol1;
 Var i,j,k : Integer;
     z     : arg_reel;
 BEGIN
   For j:=1 to r do
   begin         (* Solution of Ly=b  *)
     z:=b[i][j];
     For i:=1 to n do
     begin
       z:=b[i][j];
       For k:=i-1 downto 1 do z:=z-a^[i][k]*x[k][j];
       x[i][j]:=z*p^[i];
     end; (* i *)
     For i:=n downto 1 do     (* Solution of Ux=y *)
     begin
       z:=x[i][j];
       For k:=i+1 to n do
       z:= z - a^[k][i]*x[k][j];
       x[i][j]:=z*p^[i];
     end;  (* i *)
   end; (* j *)
 END;  {Cholsol1}

{**********************************************************************
*      Tred2.Inc - Version 1.1 du 31/8/1987 - J.P.DUMONT              *
* Ref: Handbook for automatic computation Volume II Linear Algebra    *
*      J.H. Wilkinson et C.Reinsch, Springer Verlag, 1971             *
* ------------------------------------------------------------------- *
* HOUSEHOLDER REDUCTION OF A SYMMETRIC MATRIX A TO A TRIDIAGONAL FORM *
*                                                                     *
* Cette proc�dure stocke la matrice A de d�part dans un tableau nxn   *
* et peut conserver toute l'information originale sur A. Son emploi   *
* est obligatoire quand on veut connaitre toutes les valeurs propres  *
* et tous les vecteurs propres � partir de ceux de An-1 par la proc�- *
* dure Tql2,qui est une variante de l'algorithme QR. La combinaison   *
* Tred2 et Tql2 est probablement la plus efficace des m�thodes connues*
* quand on veut l'ensemble des vecteurs propres de A. Elle donne des  *
* vecteurs propres orthogonaux � la pr�cision de la machine pr�s et   *
* donne la possibilit� d'�crire les vecteurs propres dans les colonnes*
* de A pour �conomiser la place en m�moire. Ne pas utiliser si les    *
* vecteurs propres ne sont pas demand�s.                              *
* ------------------------------------------------------------------- *
* ENTREES/INPUTS:                                                     *
*         n   Ordre de la matrice r�elle sym�trique A=A1              *
*       tol   constante d�pendant de la machine.Doit �tre initialis�  *
*             � eta/macheps o� eta est le plus petit nombre positif   *
*             repr�sentable dans le PC et macheps est le plus petit   *
*             nombre pour lequel 1+macheps>1.                         *
*         a   Tableau nxn donnant les �l�ments de la matrice sym�tri  *
*             que A. Seul le triangle inf�rieur est effectivement     *
*             utilis�. Le tableau initial a est copi� dans le tableau *
*             z. Si les noms de variables correspondant � a et z      *
*             sont choisis diff�rents, alors la matrice d'origine A   *
*             est conserv�e dans son int�grit�. S'ils sont identiques *
*             la matrice est perdue.                                  *
*                                                                     *
*                                                                     *
* SORTIES/OUTPUTS:                                                    *
*         a   Tableau nxn identique au tableau d'entr�e a, � moins    *
*             que le nom de variable soit pris le m�me pour a et z.   *
*             Dans ce cas, la sortie a est le tableau de sortie z     *
*             d�crit ci-dessous.                                      *
*         d   Tableau nx1 donnant les �l�ments diagonaux de la ma-    *
*             trice tridiagonale An-1.                                *
*         e   Tableau nx1 o� e[2] � e[n] donnent les n-1 �l�ments     *
*             hors diagonale de la matrice tridiagonale An-1.         *
*             L'�l�ment e[1] est mis � z�ro.                          *
*         z   Tableau nxn dont les �l�ments sont ceux de la matrice   *
*             orthogonale Q telle que Qt A1 Q= An-1 (c'est � dire     *
*             le produit des matrices de transformation de House-     *
*             holder).                                                *
**********************************************************************}
 PROCEDURE Tred2;

 Label skip;

 Var i,j,k,l : Integer;
     f,g,h,hh: arg_reel;

 BEGIN
   For i:=1 to n do
     For j:=1 to i do
       z^[i,j]:=a^[i,j];
   For i:=n downto 2 do
   begin
     l:=i-2; f:=z^[i,i-1]; g:=0;
     For k:=1 to l do g:=g+z^[i,k]*z^[i,k];
     h:=g+f*f;
     (* Si g est trop petit pour garantir l'orthogonalit�, alors on saute
        la transformation. *)
     if g<= tol then
     begin
       e^[i]:=f; h:=0; goto skip;
     end;
     l:=l+1;
     if f>=0 then g:=-sqrt(h) else g:=sqrt(h);
     e^[i]:=g;
     h:=h-f*g; z^[i,i-1]:=f-g; f:=0;
     For j:=1 to l do
     Begin
       z^[j,i]:=z^[i,j]/h; g:=0;
       (* Construire l'�l�ment de A*u *)
       For k:=1 to j do g:=g +z^[j,k]*z^[i,k];
       For k:=j+1 to l do g:=g +z^[k,j]*z^[i,k];
       (* Construire l'�l�ment de p *)
       e^[j]:=g/h;f:=f+e^[j]*z^[i,j];
     end; (* Boucle j *)
     (* Former K *)
     hh:=f/(h+h);
     (* Former A r�duite *)
     For j:=1 to l do
     Begin
       f:=z^[i,j]; g:=e^[j]-hh*f; e^[j]:=g;
       For k:=1 to j do z^[j,k]:=z^[j,k]-f*e^[k]-g*z^[i,k];
     End; (* Boucle j *)
     Skip: d^[i]:=h;
   End; (* Boucle i *)

   d^[1]:=0; e^[1]:=0;
   (* Accumulation des matrices de transformation *)
   For i:=1 to n do
   Begin
     l:=i-1;
     if (d^[i] <> 0 ) then
     For j:=1 to l do
     Begin
       g:=0.;
       For k:=1 to l do g:=g+z^[i,k]*z^[k,j];
       For k:=1 to l do z^[k,j]:=z^[k,j]-g*z^[k,i];
     end; (* boucle j *)
     d^[i]:=z^[i,i];
     z^[i,i]:=1;
     if l>0 then
       for j:=1 to l do
       begin
         z^[i,j]:=0;
         z^[j,i]:=0;
       end;
   End; (* Boucle i *)
 END; (* tred2 *)


(*
*********************************************************************
*      Tql2 - Version 1.0 du 9/7/1987 - J.P.DUMONT                  *
* Ref: Handbook for automatic computation Volume II Linear Algebra  *
*      J.H. Wilkinson et C.Reinsch, Springer Verlag, 1971           *
*********************************************************************
* Cette proc�dure permet de trouver toutes les valeurs propres et   *
* les vecteurs propres d'une matrice tridiagonale sym�trique. Si la *
* matrice tridiagonale T provient d'une r�duction d'Householder     *
* d'une matrice sym�trique pleine A par Tred2, alors tql2 peut �tre *
* utilis�e pour trouver les vecteurs propres de A directement, sans *
* calcul pr�alable des vecteurs propres de T. Dans tous les cas, les*
* vecteurs calcul�s sont orthogonaux � la pr�cision de la machine   *
* pr�s.                                                             *
* This procedure calculates all eigenvalues and eigenvectors of a   *
* symmetric tridiagonal matrix. If tridiagonal T matrix comes from  *
* a Householder's reduction of a general symmetric matrix A by using*
* Tred2, then Tql2 can be used to directly calculate the eigen-     *
* vectors of A, without previously calculating the eigenvalues of T.*
* In any case, the calculated vectors are orthogonal to the machine *
* accuracy.                                                         *   
*********************************************************************
* ENTREES/INPUTS:                                                   *
*         n   Ordre de la matrice tridiagonale T.                   *
*   macheps   Plus petit nombre repr�sentable sur le PC pour lequel *
*             1+macheps > 1                                         *
*         d   Tableau nx1 des �l�ments diagonaux de T.              *
*         e   Tableau nx1 des �l�ments subdiagonaux de T. e[1] n'est*
*             pas utilis� et peut �tre arbitraire.                  *
*         z   Tableau nxn �gal � la matrice identique si l'on veut  *
*             les vecteurs propres de la matrice T elle-m�me. Si T  *
*             a �t� obtenue depuis une matrice pleine par la proc�- *
*             dure tred2 alors z doit �tre la matrice de la trans-  *
*             formation de Householder fournie en sortie par cette  *
*             proc�dure.                                            *
*********************************************************************
* SORTIES/OUTPUTS:                                                  *
*         d   Tableau nx1 donnant les valeurs propres de T en ordre *
*             croissant.                                            *
*         e   est utilis� comme zone de stockage et l'information   *
*             primitive est d�truite.                               *
*         z   Tableau nxn donnant les vecteurs propres normalis�s,  *
*             colonne par colonne, de la matrice T si la matrice z  *
*             est la matrice identique, sinon ceux de la matrice    *
*             pleine primitive si T a �t� obtenue par tred2.        *
*********************************************************************
*)
 PROCEDURE Tql2;

{Calcul des valeurs propres et des vecteurs propres de Z T ZT, la
 Matrice tridiagonale T est donn�e avec ses �l�ments diagonaux dans
 le tableau d[n] et ses �l�ments subdiagonaux dans les derniers
 n-1 registres du tableau e[n], en employant les transformations QL.
     Les valeurs propres viennent �craser les �l�ments diagonaux du
 tableau d en ordre croissant. Les vecteurs propres sont construits
 dans le tableau z(nxn) , en �crasant la matrice de transformation
 orthogonale Z fournie en entr�e. La proc�dure �choue si une quel-
 conque des valeurs propres demande plus de 30 it�rations. }

 VAR i,j,k,l,m : Integer;
     b,c,f,g,h,p,r,s,den : arg_reel;

 Label cont,nextit,root;

 BEGIN
   Erreur:=False;
   For i:=2 to n do e^[i-1]:=e^[i];
   f:=0; b:=f; e^[n]:=f;
   For l:= 1 to n do
   begin
     j:=0;
     h:=macheps*(abs(d^[l])+abs(e^[l]));
     if b<h then b:=h;
     (* chercher le plus petit �l�ment subdiagonal *)
     For m:=l to n do if abs(e^[m]) <=b then goto cont;
     cont: if m=l then goto root;
     nextit: if j=30 then
     begin
       erreur:=true;
       exit;
     end;
     j:=j+1;
     (* Construire le d�calage *)
     g:=d^[l];p:=(d^[l+1]-g)/(2*e^[l]); r:=sqrt(p*p+1);
     if (p <0 ) then den:=p-r else den :=p+r;
     d^[l]:=e^[l]/den;
     h:=g-d^[l];
     For i:=l+1 to n do d^[i]:=d^[i]-h;
     f:=f+h;

     (* Transformation QL *)
     p:=d^[m]; c:=1 ; s:=0;
     For i:=m-1 downto l do
     begin
         g:=c*e^[i];
         h:=c*p;
         if abs(p) >= abs(e^[i]) then
               begin
                    c:=e^[i]/p;
                    r:=sqrt(c*c+1);
                    e^[i+1]:=s*p*r;
                    s:=c/r;
                    c:=1/r;
               end
               else
               begin
                    c:=p/e^[i];
                    r:=sqrt(c*c+1);
                    e^[i+1]:=s*e^[i]*r;
                    s:=1/r;
                    c:=c/r;
               End;
               p:=c*d^[i]-s*g;
               d^[i+1]:=h+s*(c*g+s*d^[i]);
               (* construire le vecteur *)
               For k:=1 to n do
               begin
                    h:=z^[k,i+1];
                    z^[k,i+1]:=s*z^[k,i]+c*h;
                    z^[k,i]:=c*z^[k,i]-s*h;
               end; (* boucle k *)
     end; (* Boucle i *)
     e^[l]:=s*p;
     d^[l]:=c*p;
     if (abs(e^[l])> b) then goto Nextit;

     root:d^[l]:= d^[l]+f;
   end; (* Boucle l *)

   (* ordonner les valeurs propres et les vecteurs propres *)
   For i:= 1 to n do
   Begin
     k:=i; p:=d^[i];
     For j:=i+1 to n do
     if d^[j] < p then
     begin k:=j; p:=d^[j];
     end;
     if (k<>i) then
     begin d^[k] := d^[i]; d^[i] :=p;
           For j:=1 to n do
           begin p:=z^[j,i];
                 z^[j,i]:=z^[j,k];
                 z^[j,k]:=p;
           end; (* boucle j *)
     end; (* if *)
   End; (* Boucle i *)
 End; (* tql2 *)


{     Probl�me g�n�ralis� aux valeurs propres  K X = � M X
      ----------------------------------------------------
      Les matrices K et M sont sym�triques et M est d�finie positive.
La proc�dure REDUC1 r�duit le probl�me � sa forme standard pour une
matrice sym�trique P au moyen d'une d�composition de Cholevsky de M.
Le probl�me aux valeurs propres de P peut alors �tre r�solu par les
m�thodes classiques (Jacobi, Householder+QL ...). On revient ensuite
aux vecteurs propres du probl�me initial par la proc�dure REBAKA.
      Il faut remarquer que m�me si K et M sont des matrices bande
�troite, la matrice P sera pleine. Dans ce cas, il n'est pas recommand�
d'utiliser ces algorithmes. Employer plut�t RITZIT.

************************************************************************
* Reduc1 - Version 1.1 du 23/8/1987 - J.P.DUMONT                       *
* Ref: Handbook for automatic computation Volume II Linear Algebra     *
*      J.H. Wilkinson et C.Reinsch, Springer Verlag, 1971              *
************************************************************************
* R�duction du probl�me aux valeurs propres Ax = � Bx � la forme sym�- *
* trique standard Pz = � z o� P=L-1 A LT et B= L LT.                   *
************************************************************************
* Entr�es:                                                             *
*         n    ordre des matrices A et B, ou ordre n�gatif si L existe *
*              d�ja.                                                   *
*         a    �l�ments de la matrice sym�trique A donn�e comme partie *
*              triangulaire sup�rieure d'un tableau nxn .  (La partie  *
*              triangulaire strictement inf�rieure peut �tre arbitraire*
*         b    �l�ments de la matrice B sym�trique d�finie positive    *
*              donn�e comme partie triangulaire sup�rieure d'un tableau*
*              nxn. (La partie triangulaire strictement inf�rieure peut*
*              �tre arbitraire.                                        *
************************************************************************
* Sorties:                                                             *
*         a    �l�ments de la matrice sym�trique P=L-1 A L-1T          *
*              donn�e comme triangle inf�rieur d'un tableau nxn . Le   *
*              triangle strictement sup�rieur de A est pr�serv�, mais  *
*              sa diagonale est perdue.                                *
*         b    �l�ments sous diagonaux de la matrice L telle que LLT=B *
*              est stock�e comme triangle inf�rieur strict d'un tableau*
*              nxn.                                                    *
*         dl   �l�ments diagonaux de L stock�s en tableau nx1.         *
*                                                                      *
*       Exit   sortie utilis�e si B, par suite d'erreurs d'arrondi,    *
*              n'est pas d�finie positive.                             *
***********************************************************************}
 PROCEDURE Reduc1;
 Var i,j,k: Integer;
     x,y  : arg_reel;
 BEGIN
   Erreur:=False;
   If ( n < 0 ) then n:= -n
             else
             For i:=1 to n do
             For j:=i to n do
             begin
                  x:=b^[i,j];
                  For k:=i-1 downto 1 do
                  x:=x-b^[i,k]*b^[j,k];
                  if i=j then
                  begin if x<=0 then
                                begin
                                erreur:=true;
                                exit;
                                end;
                        y:=sqrt(x);
                        dl^[i]:=y;
                  end
                  else b^[j,i]:=x/y;
                  end; (* Boucles i,j *)
   (* La matrice L a �t� construite dans le tableau b *)
   For i:=1 to n do
   begin
     y:=dl^[i];
       For j:=i to n do
       begin
         x:=a^[i,j];
         For k:=i-1 downto 1 do x:=x-b^[i,k]*a^[j,k];
         a^[j,i]:=x/y;
       end;  (* Boucle j *)
   end;   (* Boucle i *)
  (*
    La transpos�e du triangle sup�rieur de inv(L)*A a �t� construite
    dans le triangle inf�rieur du tableau A
  *)
   For j:=1 to n do
     For i:=j to n do
     Begin
       x:=a^[i,j];
       For k:=i-1 downto j do x:=x - a^[k,j]*b^[i,k];
       For k:=j-1 downto 1 do
       x:=x - a^[j,k]*b^[i,k];
       a^[i,j]:=x/dl^[i];
     End; (* Boucle i *)
 End; (* Reduc1 *)

{***********************************************************************
* Rebaka  - Version 1.0 du 8/7/1987 - J.P.DUMONT                       *
* Ref: Handbook for automatic computation Volume II Linear Algebra     *
*      J.H. Wilkinson et C.Reinsch, Springer Verlag, 1971              *
************************************************************************
* Construction des vecteurs propres du probl�me Ax = � Bx � partir     *
* des vecteurs propres correspondants z=L-1 y du probl�me sym�trique   *
* standard associ�.                                                    *
************************************************************************
* Entr�es:                                                             *
*         n     Ordre des matrices A et B                              *
*         m1,m2 Les vecteurs propres m1..m2 du probl�me sym�trique     *
*               standard associ� ont �t� trouv�s.                      *
*         b     Les �l�ments subdiagonaux de la matrice L tels que     *
*               L.LT= B est stock�e dans le triangle strictement in-   *
*               f�rieur d'un tableau nxn (fourni par Reduc1).          *
*        dl     Les �l�ments diagonaux de L stock�s dans tableau nx1   *
*                                                                      *
*         z     Tableau nx(m2-m1+1) contenant les vecteurs propres     *
*               m1,..,m2 du probl�me sym�trique associ�                *
************************************************************************
* Sorties:                                                             *
*         z     Tableau nx(m2-m1+1) contenant les vecteurs propres du  *
*               probl�me initial.                                      *
*               z sortie = Transpos�e(L-1)x (z entr�e)                 *
***********************************************************************}
 PROCEDURE Rebaka  (n,m1,m2:Integer;
                    b:pMatc;
                    dl:pVect;
                    Var z: pMatc);
 Var i,j,k :Integer;
     x     :arg_reel;
 Begin
   For j:=m1 to m2 do
   begin
     For i:= n downto 1 do
     begin
       x:=z^[i,j];
       For k:=i+1 to n do x:=x-b^[k,i]*z^[k,j];
       z^[i,j]:=x/dl^[i];
     end; (* i *)
   end;  (* j *)
 End;  (* Rebaka *)

 END.

{end of file algeblin.pas}
