function [out,T] = CreateSampleGUI(P)
% close all
%% (* Create a sample *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Please enter the elemental formula of the material/sample. When "E" ist
% the shortname of the element and "n" its stoichiometry, the formula has
% to look like this: "E1n1 E2n2 E3n3 ..." e.g. "Al2 O3, W1 C1, Ti1 C1 N1"
ElementalFormula = P.ElementalFormula;
% Enter the name of the *.mpd file (without .mpd) which stores the material
% information (e.g. LatticeParameter, crystal structure etc.)
MPDFileName = P.MPDFileName;
% Additonally show the peaks of the substrate or any other second phase.
% (if yes = true, if not = false)
ShowSubstratePeaks = P.ShowSubstratePeaks;
if (ShowSubstratePeaks) == 1
% Please enter the elemental formula of the substrate/second phase etc.
% It is also possible now to plot diffractions peaks of an additional phase
% from within the "PlotCurrentMeasData" figure. The diffraction lines can
% be deleted from the plot, whereas the substrate peaks are always visible.
SubstrateFormula = P.SubstrateFormula;
% Enter the name of the substrate *.mpd file (without .mpd) which stores 
% the material information (e.g. LatticeParameter, crystal structure etc.)
SusbtrateMPDFileName = P.SusbtrateMPDFileName;
else
    ShowSubstratePeaks = false;
end
% Clean up all temporary variables.
CleanUpTemporaryVariables = false;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Create a sample object.
T.Material = Sample.Material();
T.Material.ElementalFormula = ElementalFormula;
T.Material.GetElementsFromFormula();
% Import and read the mpd file.
T.MaterialInfo = T.Material.LoadFromMpdFile(MPDFileName);
% Assign the respective property of the material.
T.Material.MaterialDensity = T.MaterialInfo.MaterialDensity;
T.Material.LatticeParameter = T.MaterialInfo.LatticeParameter;
T.Material.CrystalStructure = T.MaterialInfo.CrystalStructure;
T.Material.MolecularWeight = T.MaterialInfo.MolecularWeight;
T.Material.HKLdspacing = T.MaterialInfo.HKLdspacing;
if (ShowSubstratePeaks) == 1
T.Material.ShowSubstratePeaks = true;
else
T.Material.ShowSubstratePeaks = false;  
end
T.Material.Name = MPDFileName;
% Default value for maximum energy.
T.Material.EnergyMax = 100;

T.Substrate = Sample.Substrate();

if (ShowSubstratePeaks) == 1
    % Create a sample object.
    T.Substrate = Sample.Substrate();
    T.Substrate.ElementalFormula = SubstrateFormula;
    T.Substrate.GetElementsFromFormula();
    % Import and read the mpd file.
    T.SusbtrateInfo = T.Substrate.LoadFromMpdFile(SusbtrateMPDFileName);
    % Assign the respective property of the substrate.
    T.Substrate.MaterialDensity = T.SusbtrateInfo.MaterialDensity;
    T.Substrate.LatticeParameter = T.SusbtrateInfo.LatticeParameter;
    T.Substrate.CrystalStructure = T.SusbtrateInfo.CrystalStructure;
    T.Substrate.MolecularWeight = T.SusbtrateInfo.MolecularWeight;
    T.Substrate.HKLdspacing = T.SusbtrateInfo.HKLdspacing;
    T.Substrate.Name = SusbtrateMPDFileName;
    % Default value for maximum energy.
    T.Substrate.EnergyMax = 100;
end
% Create a sample object.
SampleOut = Sample.Sample();
% Choose sample structre (not intended to be changed as yet).
SampleOut.Structure = 'PhaseMixture';
% Assign the materials information to the sample object.
SampleOut.Materials = T.Material;
% Assign the substrate/additional phase information to the sample object.

SampleOut.Substrate = T.Substrate;

if (ShowSubstratePeaks) == 1
    SampleOut.Substrate = T.Substrate;
end
% Clean up all temporary variables.
if (CleanUpTemporaryVariables)
    clear('P');
%     clear('T');
end
out = SampleOut;
disp('sample created');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++