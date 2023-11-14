clear all
%% (* Create a sample *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Please enter the elemental formula of the material/sample. When "E" ist
% the shortname of the element and "n" its stoichiometry, the formula has
% to look like this: "E1n1 E2n2 E3n3 ..." e.g. "Al2 O3, W1 C1, Ti1 C1 N1"
P.ElementalFormula = 'Au1';                                     % <--
% Enter the name of the *.mpd file (without .mpd) which stores the material
% information (e.g. LatticeParameter, crystal structure etc.)
P.MPDFileName = 'Au';                                               % <--
% Additonally show the peaks of the substrate or any other second phase.
% (if yes = true, if not = false)
P.ShowSubstratePeaks = false;                                          % <--
if (P.ShowSubstratePeaks)
% Please enter the elemental formula of the substrate/second phase etc.
% It is also possible now to plot diffractions peaks of an additional phase
% from within the "PlotCurrentMeasData" figure. The diffraction lines can
% be deleted from the plot, whereas the substrate peaks are always visible.
P.SubstrateFormula = 'W1 C1';                                         % <--
% Enter the name of the substrate *.mpd file (without .mpd) which stores 
% the material information (e.g. LatticeParameter, crystal structure etc.)
P.SusbtrateMPDFileName = 'WC';                                        % <--
end
% Clean up all temporary variables.
P.CleanUpTemporaryVariables = false;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Create a sample object.
T.Material = Sample.Material();
T.Material.ElementalFormula = P.ElementalFormula;
T.Material.GetElementsFromFormula();
% Import and read the mpd file.
T.MaterialInfo = T.Material.LoadFromMpdFile(P.MPDFileName);
% Assign the respective property of the material.
T.Material.MaterialDensity = T.MaterialInfo.MaterialDensity;
T.Material.LatticeParameter = T.MaterialInfo.LatticeParameter;
T.Material.CrystalStructure = T.MaterialInfo.CrystalStructure;
T.Material.MolecularWeight = T.MaterialInfo.MolecularWeight;
T.Material.HKLdspacing = T.MaterialInfo.HKLdspacing;
T.Material.ShowSubstratePeaks = P.ShowSubstratePeaks;
T.Material.Name = P.MPDFileName;
% Default value for maximum energy.
T.Material.EnergyMax = 100;

T.Substrate = Sample.Substrate();

if (P.ShowSubstratePeaks)
    % Create a sample object.
    T.Substrate = Sample.Substrate();
    T.Substrate.ElementalFormula = P.SubstrateFormula;
    T.Substrate.GetElementsFromFormula();
    % Import and read the mpd file.
    T.SusbtrateInfo = T.Substrate.LoadFromMpdFile(P.SusbtrateMPDFileName);
    % Assign the respective property of the substrate.
    T.Substrate.MaterialDensity = T.SusbtrateInfo.MaterialDensity;
    T.Substrate.LatticeParameter = T.SusbtrateInfo.LatticeParameter;
    T.Substrate.CrystalStructure = T.SusbtrateInfo.CrystalStructure;
    T.Substrate.MolecularWeight = T.SusbtrateInfo.MolecularWeight;
    T.Substrate.HKLdspacing = T.SusbtrateInfo.HKLdspacing;
    T.Substrate.Name = P.SusbtrateMPDFileName;
    % Default value for maximum energy.
    T.Substrate.EnergyMax = 100;
end
% Create a sample object.
Sample = Sample.Sample();
% Choose sample structre (not intended to be changed as yet).
Sample.Structure = 'PhaseMixture';
% Assign the materials information to the sample object.
Sample.Materials = T.Material;
% Assign the substrate/additional phase information to the sample object.

Sample.Substrate = T.Substrate;

if (P.ShowSubstratePeaks)
    Sample.Substrate = T.Substrate;
end
% Clean up all temporary variables.
if (P.CleanUpTemporaryVariables)
    clear('P');
    clear('T');
end

disp('sample created');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++