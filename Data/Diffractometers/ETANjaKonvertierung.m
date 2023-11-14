BeginPackage["ETAnjaKonvertierung`"];



$ContextPath = 
{"Global`","System`",
"Statistics`NonlinearFit`","Statistics`LinearRegression`",
"Statistics`ConfidenceIntervals`","Statistics`ConfidenceIntervals`",
"Statistics`NormalDistribution`","Statistics`DescriptiveStatistics`", 
"Statistics`Common`MultivariateCommon`","Statistics`Common`PopulationsCommon`",
"Statistics`Common`RegressionCommon`","Statistics`Common`PopulationsCommon`",
"Statistics`Common`DistributionsCommon`","Graphics`Graphics3D`",
"Graphics`Graphics`","Graphics`Colors`","Graphics`Legend`",
"Graphics`MultipleListPlot`","Graphics`Common`GraphicsCommon`",
"Utilities`FilterOptions`","Calculus`FourierTransform`",
"ETAbasic`","ETArek`","ETAnjaKonvertierung`","ETAspecfileKonvertierung`","ETAspannungsanalyse`","ETAtextur`"};


(*---------------------------------------------------------------------------
NjaKonvertierung

Am Laborgerät ETA werden *.NJC files gemessen, die anschließend vom Programm 
Analyze in *.nja files (ASCII-Format) umgewandelt werden können. Das Modul
konvertiert die *.nja files in *.dat files, die für die weitere Datenanalyse
werden.
----------------------------------------------------------------------------*)

NjaFilekonvertierung[	Datei               -> fileName_String,
                        Messmodus           -> messmod_,
                        Countspersecond     -> cpsantw_,
                        Rumpfdateiname      -> rumpf_String]:=
Module[{},

SetDirectory[datenpfad];

file = OpenRead[fileName];
modus = messmod;

(* Stringenzprüfungen *)

If[	MatchQ[file,$Failed],
	   	Print[" "];
	   	Print["Datei ",fileName," existiert nicht!"];
	   	Close[fileName];
	   	Abort[]];

If[ modus < 1 || modus > 3,
    Print["Falscher Messmodus!"];
    Abort[]];

ausgabefilename = rumpf;

(* Gesamtes File als String *)

Messung=ReadList[file,String,RecordLists->True];
Close[fileName];

Clear[sample,anode,filter,spannung,strom,detektor];

(* Auslesen von Kennwerte aus dem Kopf *)

(* Sample *)

samplestringlaenge=StringLength[Messung[[1,3]]];  
samplepos=StringPosition[Messung[[1,3]],"&Sample="]; 
sample=StringTake[Messung[[1,3]],{samplepos[[1,2]]+1,samplestringlaenge}];

(* Anode *)

tabposanode=StringPosition[Messung[[1,6]],"\t"];  
anodepos=StringPosition[Messung[[1,6]],"&Anode="]; 
anode=StringTake[Messung[[1,6]],{anodepos[[1,2]]+1,tabposanode[[1,1]]-1}];

(* Filter *)

filterpos=StringPosition[Messung[[1,6]],"&Filter="]; 
filter=StringTake[Messung[[1,6]],{filterpos[[1,2]]+1,tabposanode[[2,1]]-1}];

(* Spannung *)

spannungpos=StringPosition[Messung[[1,6]],"&kV="]; 
spannung=ToExpression[StringTake[Messung[[1,6]],{spannungpos[[1,2]]+1,tabposanode[[3,1]]-1}]];

(* Strom *)

anodestringlaenge=StringLength[Messung[[1,6]]]; 
strompos=StringPosition[Messung[[1,6]],"&mA="]; 
strom=ToExpression[StringTake[Messung[[1,6]],{strompos[[1,2]]+1,anodestringlaenge}]];

(* Detektor *)

detstringlaenge=StringLength[Messung[[1,7]]]; 
detpos=StringPosition[Messung[[1,7]],"&Detector="]; 
detektor=StringTake[Messung[[1,7]],{detpos[[1,2]]+1,detstringlaenge}];

(* Anzahl der Scans aus dem Kopf auslesen *)

If[StringTake[Messung[[2,2]],{2,StringLength[Messung[[2,2]]]}] == ToString[StressParameter],
tabposscananzahl=StringPosition[Messung[[2,3]],"\t"]; 
numposscananzahl=StringPosition[Messung[[2,3]],"&NumScans="]; 
scananzahl=ToExpression[StringTake[Messung[[2,3]],{numposscananzahl[[1,2]]+1,tabposscananzahl[[1,1]]-1}]]];
If[StringTake[Messung[[2,2]],{2,StringLength[Messung[[2,2]]]}] == ToString[CommonParameter],
scanstringlaenge=StringLength[Messung[[2,3]]]; 
numposscananzahl=StringPosition[Messung[[2,3]],"&NumScans="]; 
scananzahl=ToExpression[StringTake[Messung[[2,3]],{numposscananzahl[[1,2]]+1,scanstringlaenge}]]];



Print["Die Anzahl der Scans betraegt: ",scananzahl];
Print[""];

For[i=1,i <= scananzahl,i++,	(* Arbeitet die einzelnen Scans ab *)

    Print["Scannummer ",i," wird ausgewertet:"];
   
    l=Length[Messung[[2i+1]]];	(* Länge der Messköpfe *)

	Clear[chistring,phistring,phistrichstring,xstring,ystring,zstring,psi,psiP,phi,phiP,
		etaP,phistrich,xdiff,ydiff,zdiff,inttime,lauf1,lauf2,lauf3,lauf4,lauf5,lauf6];

	(* Kontrolle von Spannung und Strom *)
	
	tabposspannung2=StringPosition[Messung[[2i+1,3]],"\t"];  
	spannung2pos=StringPosition[Messung[[2i+1,3]],"&kV="]; 
	spannung2=ToExpression[StringTake[Messung[[2i+1,3]],{spannung2pos[[1,2]]+1,tabposspannung2[[1,1]]-1}]];
	
	strom2stringlaenge=StringLength[Messung[[2i+1,3]]]; 
	strom2pos=StringPosition[Messung[[2i+1,3]],"&mA="]; 
	strom2=ToExpression[StringTake[Messung[[2i+1,3]],{strom2pos[[1,2]]+1,strom2stringlaenge}]];
	
	If[spannung2=!=0, spannung=spannung2];
	If[strom2=!=0, strom=strom2];
		
	(* Auslesen von psi *)
	
    For[n1=1,n1 <= l,n1++,
       chistring=StringPosition[Messung[[2i+1,n1]],"&Axis=C\t&Task=Drive\t&Pos="];
       If[chistring[[1,1]] == 1,lauf1=n1;chistringend=chistring[[1,2]]]];
	
    (* ist kein "Drive" vorhanden, so wird nach "GetPosition" gesucht *)
    
    If[NumberQ[lauf1]==False,
	   For[n1=1,n1 <= l,n1++,
       	chistring=StringPosition[Messung[[2i+1,n1]],"&Axis=C\t&Task=GetPosition\t&Pos="];
       	If[chistring[[1,1]] == 1,lauf1=n1;chistringend=chistring[[1,2]]]]];
       
    psiString=StringTake[Messung[[2i+1,lauf1]],{chistringend+1,chistringend+8}];
    psi=ToExpression[psiString];
    psiP=psi;
    
    (* Auslesen von phi *)
	
    For[n2=1,n2 <= l,n2++,
       phistring=StringPosition[Messung[[2i+1,n2]],"&Axis=P\t&Task=Drive\t&Pos="];
       If[phistring[[1,1]] == 1,lauf2=n2;phistringend=phistring[[1,2]]]];
	
    (* ist kein "Drive" vorhanden, so wird nach "GetPosition" gesucht *)
    
    If[NumberQ[lauf2]==False,Print[ja];
	   For[n2=1,n2 <= l,n2++,
       	phistring=StringPosition[Messung[[2i+1,n2]],"&Axis=P\t&Task=GetPosition\t&Pos="];
       	If[phistring[[1,1]] == 1,lauf2=n2;phistringend=phistring[[1,2]]]]];
       
    phiString=StringTake[Messung[[2i+1,lauf2]],{phistringend+1,phistringend+8}];
    phi=ToExpression[phiString];
    phiP=phi;
    
	(* Auslesen von phistrich *)

    For[n3=1,n3 <= l,n3++,
        phistrichstring=StringPosition[Messung[[2i+1,n3]],"&Axis=PH\t&Task=Drive\t&Pos="];
		If[phistrichstring[[1,1]] == 1,lauf3=n3;phistrichstringend=phistrichstring[[1,2]]]];
		
	(* ist kein "Drive" vorhanden, so wird nach "GetPosition" gesucht *)
    
    If[NumberQ[lauf3]==False,
	   For[n3=1,n3 <= l,n3++,
       	phistrichstring=StringPosition[Messung[[2i+1,n3]],"&Axis=PH\t&Task=GetPosition\t&Pos="];
       	If[phistrichstring[[1,1]] == 1,lauf3=n3;phistrichstringend=phistrichstring[[1,2]]]]];
		
	phistrichString=StringTake[Messung[[2i+1,lauf3]],{phistrichstringend+1,phistrichstringend+8}];
    phistrich=ToExpression[phistrichString];
    		
	(*  Berechnung von eta aus phistrich *)

    etaP = Abs[90-phistrich];  (* Diese Konvention gilt für alle Modi! *)
    Print["psiP = ", psiP,"°, phiP = ", phiP,"°, etaP = ", etaP,"°"];

	(* Auslesen von xdiff *)
	
    For[n4=1,n4 <= l,n4++,
       xstring=StringPosition[Messung[[2i+1,n4]],"&Axis=A\t&Task=Drive\t&Pos="];
       If[xstring[[1,1]] == 1,lauf4=n4;xstringend=xstring[[1,2]]]];
	
    (* ist kein "Drive" vorhanden, so wird nach "GetPosition" gesucht *)
    
    If[NumberQ[lauf4]==False,
	   For[n4=1,n4 <= l,n4++,
       	xstring=StringPosition[Messung[[2i+1,n4]],"&Axis=A\t&Task=GetPosition\t&Pos="];
       	If[xstring[[1,1]] == 1,lauf4=n4;xstringend=xstring[[1,2]]]]];
       
    xString=StringTake[Messung[[2i+1,lauf4]],{xstringend+1,xstringend+8}];
    xdiff=ToExpression[xString];
       
	(* Auslesen von ydiff *)
	
    For[n5=1,n5 <= l,n5++,
       ystring=StringPosition[Messung[[2i+1,n5]],"&Axis=B\t&Task=Drive\t&Pos="];
       If[ystring[[1,1]] == 1,lauf5=n5;ystringend=ystring[[1,2]]]];
	
    (* ist kein "Drive" vorhanden, so wird nach "GetPosition" gesucht *)
    
    If[NumberQ[lauf5]==False,
	   For[n5=1,n5 <= l,n5++,
       	ystring=StringPosition[Messung[[2i+1,n5]],"&Axis=B\t&Task=GetPosition\t&Pos="];
       	If[ystring[[1,1]] == 1,lauf5=n5;ystringend=ystring[[1,2]]]]];
       
    yString=StringTake[Messung[[2i+1,lauf5]],{ystringend+1,ystringend+8}];
    ydiff=ToExpression[yString];    
 
	(* Auslesen von zdiff *)
	
    For[n6=1,n6 <= l,n6++,
       zstring=StringPosition[Messung[[2i+1,n6]],"&Axis=D\t&Task=Drive\t&Pos="];
       If[zstring[[1,1]] == 1,lauf6=n6;zstringend=zstring[[1,2]]]];
	
    (* ist kein "Drive" vorhanden, so wird nach "GetPosition" gesucht *)
    
    If[NumberQ[lauf6]==False,
	   For[n6=1,n6 <= l,n6++,
       	zstring=StringPosition[Messung[[2i+1,n6]],"&Axis=D\t&Task=GetPosition\t&Pos="];
       	If[zstring[[1,1]] == 1,lauf6=n6;zstringend=zstring[[1,2]]]]];
       
    zString=StringTake[Messung[[2i+1,lauf6]],{zstringend+1,zstringend+8}];
    zdiff=ToExpression[zString];  
    
    (* Auslesen der Integrationszeit *)
	
    tabpostime=StringPosition[Messung[[2i+1,5]],"\t"]; 
	timepos=StringPosition[Messung[[2i+1,5]],"&Time="]; 
	timewert=ToExpression[StringTake[Messung[[2i+1,5]],{timepos[[1,2]]+1,tabpostime[[4,1]]-1}]];
	If[ cpsantw == nein, inttime = timewert];
	If[ cpsantw == ja, inttime = N[1]];
	
	(* Erzeugung des timestring *)
	
	datum = Date[];
    timestring=StringJoin[ToString[datum[[3]]], "-", ToString[datum[[2]]], "-", 
  				ToString[datum[[1]]], " ", ToString[datum[[4]]], ":", 
  				ToString[datum[[5]]], ":", ToString[datum[[6]]]];   
    
  	(* Outputfilename *)
				    
    iString=ToString[i];
    Which[i<10,name=StringJoin[ausgabefilename,"-00",iString,".dat"],   
          10<=i<100,name=StringJoin[ausgabefilename,"-0",iString,".dat"],
          i>=100,name=StringJoin[ausgabefilename,"-",iString,".dat"]];
          
    strm=OpenWrite[name,FormatType->OutputForm];
    Write[strm,"StammDatei: ",fileName];
    Write[strm,"sample","= "sample];
    Write[strm,"time","= ",timestring];
    Write[strm,"phi","= ",phi,"°"];
    Write[strm,"chi","= ",psi,"°"];
    Write[strm,"phistrich","= ",phistrich,"°"];
    Write[strm,"x= ",xdiff,"mm"];
	Write[strm,"y= ",ydiff,"mm"];
	Write[strm,"z= ",zdiff,"mm"];
	Write[strm,"phiP= ",phiP,"°"];
	Write[strm,"psiP= ",psiP,"°"];
	Write[strm,"etaP= ",etaP,"°"];
	Write[strm,"lifetime= ",inttime," s"];
	Write[strm,"realtime= ",inttime," s"];
	Write[strm,"Anode","= ",anode];
	Write[strm,"Filter","= ",filter];
	Write[strm,"Spannung= ",spannung,"kV"];
	Write[strm,"Strom= ",strom,"mA"];
	Write[strm,"Detector","= ",detektor];
	Write[strm,"messmodus= ",modus];
    WriteString[strm,"\nNumber\t2Theta\tCounts\n"];
 
     (* Datenliste einlesen *)
   
    j=Length[Messung[[2i+2]]]; 	(* Länge des Datenteils der einzelnen Messungen *)
       
    For[k=4,k <= j,k++,        
        winkelString=StringTake[Messung[[2i+2,k]],{1,10}]; 
        winkel=ToExpression[winkelString];
        ctsString=StringTake[Messung[[2i+2,k]],{12,22}];

        If[ cpsantw == nein,
            cts=ToExpression[ctsString]];

        If[ cpsantw == ja,
            cts=N[ToExpression[ctsString]/inttime]];
   
        Write[strm,PaddedForm[k-4,{3,0}],
                   "   ", 
                   PaddedForm[winkel,{8,5}],
                   "   ",
                   PaddedForm[cts,{10,3}]];
      
       ]; (* Ende der For-Schleife *)

   Close[strm];

  
   ]; (* ende der forschleife *)

	Print[StyleForm["Die Filekonvertierung ist beendet!",
			FontFamily -> "Arial",FontWeight -> "Bold",
			FontSize -> 12,	FontColor -> RGBColor[1,0,0]]];
     
]; (* Ende des Moduls NjaFilekonvertierung *)


EndPackage[]