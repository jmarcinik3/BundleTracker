classdef TrackingGui < handle
    properties (Access = private, Constant)
        queueColor = "red";
        workingColor = "yellow";
        finishedColor = "green";
    end

    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>

        intensityThresholds;
        rawImage = [];

        % main window components
        figure; % uifigure containing GUI
        gridLayout; % uigridlayout containing GUI components

        % components to select and display bundle images
        bundleDisplay; % BundleDisplay object
        directorySelector; % DirectorySelector

        % components to set preprocessing and tracking methods
        thresholdSlider;
        invertCheckbox
        trackingSelection;

        % components to set postprocessing methods
        kinociliumLocation;
        scaleFactorInputElement;
        fpsInputElement;

        % components to start tracking and save results
        trackButton;
        saveImageButton;
        saveFilestemElement;
    end

    methods
        function obj = TrackingGui(varargin)
            p = inputParser;
            addOptional(p, "StartingDirectory", "");
            addOptional(p, "EnableZoom", true);
            parse(p, varargin{:});
            startingDirpath = p.Results.StartingDirectory;
            enableZoom = p.Results.EnableZoom;
            
            gl = obj.generateGridLayout();
            obj.generateSimpleElements(gl);
            obj.generateBundleDisplay(gl, enableZoom);
            obj.generateDirectorySelector(gl, startingDirpath); % must come last
            layoutElements(obj);
        end
    end

    %% Functions to retrieve state information
    methods (Access = private)
        % ...bundle display
        function dirpath = getDirectoryPath(obj)
            elem = obj.directorySelector;
            dirpath = elem.getDirectoryPath();
        end
        function filepath = getFirstFilepath(obj)
            filepath = obj.directorySelector.getFirstFilepath();
        end
        function filepath = generateSaveFilepath(obj, suffix)
            directoryPath = obj.getDirectoryPath();
            filestem = obj.getSaveFilestem();
            filename = sprintf("%s%s.mat", filestem, suffix);
            filepath = fullfile(directoryPath, filename);
        end
        function count = getFilecount(obj)
            count = obj.directorySelector.getFilecount();
        end
        
        % ...for preprocessing
        function processor = getPreprocessor(obj)
            thresholds = obj.getThresholds();
            invert = obj.getInvert();
            processor = Preprocessor(thresholds, invert);
            processor = @processor.preprocess;
        end
        function vals = getThresholds(obj)
            vals = obj.intensityThresholds;
        end
        function invert = getInvert(obj)
            invert = obj.invertCheckbox.Value;
        end

        % ...for tracking
        function regs = getTrackingRegions(obj)
            regs = obj.bundleDisplay.getRegions();
        end
        function paths = getFilepaths(obj)
            paths = obj.directorySelector.getFilepaths();
        end
        function val = getTrackingSelection(obj)
            val = obj.trackingSelection.Value;
        end

        % ...for postprocessing
        function loc = getKinociliumLocation(obj)
            loc = obj.kinociliumLocation.getLocation();
        end
        function factor = getScaleFactor(obj)
            gl = obj.scaleFactorInputElement;
            textbox = gl.Children(2);
            factor = textbox.Value;
        end
        function err = getScaleFactorError(obj)
            gl = obj.scaleFactorInputElement;
            textbox = gl.Children(4);
            err = textbox.Value;
        end
        function fps = getFps(obj)
            gl = obj.fpsInputElement;
            textbox = gl.Children(2);
            fps = textbox.Value;
        end
        function stem = getSaveFilestem(obj)
            gl = obj.saveFilestemElement;
            textbox = gl.Children(2);
            stem = textbox.Value;
        end
    end

    %% Functions to retrieve stored child components
    methods (Access = private)
        % complex class objects for visual components
        function fig = getFigure(obj)
            fig = obj.figure;
        end
        function ax = getBundleDisplayAxis(obj)
            ax = obj.bundleDisplay.getAxis();
        end
        function elem = getDirectorySelectionElement(obj)
            elem = obj.directorySelector.getGridLayout();
        end

        % threshold slider and invert checkbox
        function elem = getThresholdSlider(obj)
            elem = obj.thresholdSlider;
        end
        function elem = getInvertCheckbox(obj)
            elem = obj.invertCheckbox;
        end

        % components to set postprocessing methods
        function elem = getTrackingSelectionElement(obj)
            elem = obj.trackingSelection;
        end
        function elem = getKinociliumLocationElement(obj)
            elem = obj.kinociliumLocation.getElement();
        end
        function elem = getScaleFactorInputElement(obj)
            elem = obj.scaleFactorInputElement;
        end
        function elem = getFpsInputElement(obj)
            elem = obj.fpsInputElement;
        end

        % button to starting tracking and elements for saving
        function elem = getTrackButton(obj)
            elem = obj.trackButton;
        end
        function elem = getSaveImageButton(obj)
            elem = obj.saveImageButton;
        end
        function elem = getSaveFilestemElement(obj)
            elem = obj.saveFilestemElement;
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function trackButtonPushed(obj, ~, ~)
            if obj.regionExists()
                regions = obj.getTrackingRegions();
                set(regions, "Color", obj.queueColor);
                obj.trackAndSaveRegions(regions);
            end
        end
        function exists = regionExists(obj)
            regions = obj.getTrackingRegions();
            count = numel(regions);
            exists = count >= 1;
            if ~exists
                obj.throwAlertMessage("No cells selected!", "Track");
            end
        end
        function trackAndSaveRegions(obj, regions)
            for index = 1:count
                region = regions(index);
                obj.trackAndSaveRegion(region);
            end
        end
        function trackAndSaveRegion(obj, region)
            set(regions, "Color", obj.workingColor); % color region as in-process
            results = obj.trackRegion(region);
            obj.saveResults(results, region.Label);
            set(regions, "Color", obj.finishedColor); % color region as finished
        end
        function results = trackRegion(obj, region)
            trackingMode = obj.getTrackingSelection();
            preprocessor = obj.getPreprocessor();
            filepaths = obj.getFilepaths();

            results = TrackRegion( ...
                region, filepaths, trackingMode, preprocessor ...
                ); % preprocess and track
            
            results.Bounds = region.Position;
            results.TrackingMode = trackingMode;
            results = obj.appendMetadata(results);
            results = postprocessResults(results);
        end
        function results = appendMetadata(obj, results)
            results.DirectoryPath = obj.getDirectoryPath();
            results.IsInverted = obj.getInvert();
            results.IntensityRange = obj.getThresholds();
            results.KinociliumLocation = obj.getKinociliumLocation();
            results.ScaleFactor = obj.getScaleFactor();
            results.ScaleFactorError = obj.getScaleFactorError();
            results.Fps = obj.getFps();
        end
        function saveResults(obj, results, label)
            filepath = obj.generateSaveFilepath(label);
            save(filepath, "results");
        end
        
        function saveImageButtonPushed(obj, ~, ~)
            if obj.imageExists()
                directoryPath = obj.getDirectoryPath();
                obj.bundleDisplay.save(directoryPath);
            end
        end
        function exists = imageExists(obj)
            im = obj.rawImage;
            exists = numel(im) >= 1;
            if ~exists
                obj.throwAlertMessage("No image imported!", "Save Image");
            end
        end
        function thresholdSliderChanging(obj, ~, event)
            obj.intensityThresholds = event.Value;
            obj.updateBundleDisplay();
        end
        function invertCheckboxChanged(obj, ~, ~)
            obj.updateBundleDisplay();
        end
        
        function directoryValueChanged(obj, ~, ~)
            obj.imageFilepathChanged();
            obj.clearRegions();
            obj.updateBundleDisplay();
        end
        function imageFilepathChanged(obj)
            if obj.directoryHasImage()
                filepath = obj.getFirstFilepath();
                obj.rawImage = imread(filepath);
            end
        end
        function has = directoryHasImage(obj)
            count = obj.getFilecount();
            directory = obj.getDirectoryPath();
            has = count >= 1 && isfolder(directory);
            if ~has
                obj.throwAlertMessage("No valid images found!", "Choose Directory");
                obj.rawImage = [];
            end
        end
        function clearRegions(obj)
            obj.bundleDisplay.clearRegions();
        end
        function updateBundleDisplay(obj, ~, ~)
            im = obj.getPreprocessedImage();
            obj.bundleDisplay.updateImage(im);
        end
        function im = getPreprocessedImage(obj)
            im = obj.rawImage;
            im = obj.preprocessImage(im);
        end
        function im = preprocessImage(obj, im)
            if numel(im) > 0
                preprocessor = obj.getPreprocessor();
                im = preprocessor(im);
            end
        end
    
        function throwAlertMessage(obj, message, title)
            fig = obj.getFigure();
            uialert(fig, message, title);
        end
    end

    %% Functions to generate GUI elements
    methods (Access = private)
        function gl = generateGridLayout(obj)
            fig = uifigure;
            fig.Name = "Hair-Bundle Tracking";
            gl = uigridlayout(fig, [10 2]);
            obj.figure = fig;
            obj.gridLayout = gl;
        end
        function generateBundleDisplay(obj, gl, enableZoom)
            obj.bundleDisplay = BundleDisplay(gl, "EnableZoom", enableZoom);
            obj.rawImage = [];
        end
        function generateDirectorySelector(obj, gl, startingDirpath)
            obj.directorySelector = DirectorySelector( ...
                gl, ...
                "ValueChangedFcn", @obj.directoryValueChanged ...
                );
            obj.directorySelector.setDirectory(startingDirpath);
        end
        function generateSimpleElements(obj, gl)
            obj.generateTrackingElements(gl);
            obj.generatePostTrackingElements(gl);
        end
        function generateTrackingElements(obj, gl)
            obj.trackingSelection = generateTrackingSelection(gl);
            obj.kinociliumLocation = KinociliumLocation(gl);
            obj.scaleFactorInputElement = generateScaleFactorElement(gl);
            obj.fpsInputElement = generateFpsInputElement(gl);
            obj.saveFilestemElement = generateSaveFilestemElement(gl);
        end
        function generatePostTrackingElements(obj, gl)
            obj.thresholdSlider = obj.generateThresholdSlider(gl);
            obj.intensityThresholds = obj.thresholdSlider.Value;
            obj.invertCheckbox = obj.generateInvertCheckbox(gl);
            obj.trackButton = obj.generateTrackButton(gl);
            obj.saveImageButton = obj.generateSaveImageButton(gl);
        end
        
        function thresholdSlider = generateThresholdSlider(obj, gl)
            thresholdSlider = generateThresholdSlider(gl);
            set(thresholdSlider, "ValueChangingFcn", @obj.thresholdSliderChanging)
            obj.intensityThresholds = thresholdSlider.Value;
            obj.thresholdSlider = thresholdSlider;
        end
        function invertCheckbox = generateInvertCheckbox(obj, gl)
            invertCheckbox = generateInvertCheckbox(gl);
            set(invertCheckbox, "ValueChangedFcn", @obj.invertCheckboxChanged);
        end
        function trackButton = generateTrackButton(obj, gl)
            trackButton = generateTrackButton(gl);
            set(trackButton, "ButtonPushedFcn", @obj.trackButtonPushed);
        end
        function saveImageButton = generateSaveImageButton(obj, gl)
            saveImageButton = generateSaveImageButton(gl);
            set(saveImageButton, "ButtonPushedFcn", @obj.saveImageButtonPushed);
            obj.saveImageButton = saveImageButton;
        end
end
end



%% Function to lay out elements in GUI
% Lays out elements in GUI. Elements are instantiated and stored in
% constructor of TrackingGui.
%
% Arguments
%
% * TrackingGui |gui|: GUI to lay out elements in
%
% Returns void
function layoutElements(gui)
% Set components heights in grid layout
textboxHeight = 25;
dropdownHeight = 25;
buttonHeight = 25;
sliderHeight = 30;
kinociliumGroupHeight = KinociliumLocation.height;

% Retrieve components
gl = gui.gridLayout;
directorySelector = gui.getDirectorySelectionElement();
bundleAx = gui.getBundleDisplayAxis();

kinociliumLocationGroup = gui.getKinociliumLocationElement();
scaleFactorElement = gui.getScaleFactorInputElement();
fpsInputElement = gui.getFpsInputElement();

thresholdSlider = gui.getThresholdSlider();
invertCheckbox = gui.getInvertCheckbox();
trackingDropdown = gui.getTrackingSelectionElement();
saveFilestemElement = gui.getSaveFilestemElement();
trackButton = gui.getTrackButton();

saveImageButton = gui.getSaveImageButton();

% Set up hair-bundle display with region selection
bundleAx.Layout.Row = [3 9];
bundleAx.Layout.Column = 1;

% Set up section to select and display directory with images
directorySelector.Layout.Row = 1;
directorySelector.Layout.Column = [1 2];
directorySelector.RowHeight = textboxHeight;
directorySelector.ColumnWidth = {'7x', '1x', '2x', '2x'};

% Set up slider for intensity threshold to left of invert checkbox
thresholdSlider.Layout.Row = 2;
invertCheckbox.Layout.Row = 2;
thresholdSlider.Layout.Column = 1;
invertCheckbox.Layout.Column = 2;

% Set up section to select tracking method, start tracking
trackingDropdown.Layout.Row = 3;
trackButton.Layout.Row = 8;
trackingDropdown.Layout.Column = 2;
trackButton.Layout.Column = 2;

% Set up section to select kinocilium direction
kinociliumLocationGroup.Layout.Row = 4;
kinociliumLocationGroup.Layout.Column = 2;

% Set up label with textbox to set scale factor
scaleFactorElement.Layout.Row = 5;
scaleFactorElement.Layout.Column = 2;
scaleFactorElement.RowHeight = textboxHeight;
scaleFactorElement.ColumnWidth = {'3x', '3x', '1x', '2x'};

% Set up label with textbox to set FPS
fpsInputElement.Layout.Row = 6;
fpsInputElement.Layout.Column = 2;
fpsInputElement.RowHeight = textboxHeight;
fpsInputElement.ColumnWidth = {'1x', '2x'};

% Set up field to set save filestem
saveFilestemElement.Layout.Row = 7;
saveFilestemElement.Layout.Column = 2;
saveFilestemElement.RowHeight = textboxHeight;
saveFilestemElement.ColumnWidth = {'1x', '2x'};

% Set up button to save image
saveImageButton.Layout.Row = 10;
saveImageButton.Layout.Column = [1 2];

% Set up row heights and column widths for grid layout
gl.RowHeight = {
    textboxHeight, ... % directory selector
    sliderHeight, ... % threshold slider
    dropdownHeight, ... % tracking method dropdown
    kinociliumGroupHeight, ... % kinocilium group
    textboxHeight, ... % scale factor textbox
    textboxHeight, ... % fps textbox
    textboxHeight, ... % save filestem textbox
    buttonHeight, ... % track button
    '1x', ... % reserved space for image
    buttonHeight ... % save image button
    };
gl.ColumnWidth = {'2x', '1x'};
end

%% Function to generate invert checkbox
% Generates checkbox allowing user to invert image by intensity
%
% Arguments
%
% * uigridlayout |gl|: layout to add checkbox in
%
% Returns uicheckbox
function checkbox = generateInvertCheckbox(gl)
checkbox = uicheckbox(gl);
checkbox.Text = "Invert";
end

%% Function to generate tracking method dropdown
% Generates dropdown menu allowing user to select tracking method (e.g.
% "Centroid")
%
% Arguments
%
% * uigridlayout |gl|: layout to add dropdown in
%
% Returns uiddropdown
function dropdown = generateTrackingSelection(gl)
dropdown = uidropdown(gl);
dropdown.Items = TrackingAlgorithms.keywords;
end

%% Function to generate save image button
% Generates button allowing user to save displayed bundle image with
% selected regions
%
% Arguments
%
% * uigridlayout |gl|: layout to add button in
%
% Returns uibutton
function button = generateSaveImageButton(gl)
% Button to save displayed image of bundle
button = uibutton(gl);
button.Text = "Save Image";
end

%% Function to generate track button
% Generates button allowing user to starting tracking of selected regions
% on bundle image
%
% Arguments
%
% * uigridlayout |gl|: layout to add button in
%
% Returns uibutton
function button = generateTrackButton(gl)
% Button to start tracking selected regions on image
button = uibutton(gl);
button.Text = "Track";
end

%% Function to generate FPS input
% Generates edit field (with label) allowing user to set FPS
%
% Arguments
%
% * uigridlayout |parent|: layout to add edit fields in
%
% Returns uigridlayout composed of [uilabel, uieditfield("numeric")]
function gl = generateFpsInputElement(parent)
gl = uigridlayout(parent, [1 2]);
gl.Padding = [0 0 0 0];

lbl = uilabel(gl);
lbl.Text = "FPS:"; % label
tb = uieditfield(gl, "numeric");
tb.Value = 1000; % default FPS

lbl.Layout.Column = 1;
tb.Layout.Column = 2;
end

%% Function to generate scale factor input
% Generates edit fields (with labels) allowing user to set scaling (in
% nm/px) with error
%
% Arguments
%
% * uigridlayout |parent|: layout to add edit fields in
%
% Returns uigridlayout composed of [uilabel, uieditfield("numeric"),
% uilabel, uieditfield("numeric")]
function gl = generateScaleFactorElement(parent)
gl = uigridlayout(parent, [1 4]);
gl.Padding = [0 0 0 0];

lbl1 = uilabel(gl);
lbl1.Text = "nm/px:"; % label for scaling
tb1 = uieditfield(gl, "numeric");
tb1.Value = 108.3; % default scaling

lbl2 = uilabel(gl);
lbl2.Text = "±"; % label for error
tb2 = uieditfield(gl, "numeric");
tb2.Value = 0.8; % default error

lbl1.Layout.Column = 1;
tb1.Layout.Column = 2;
lbl2.Layout.Column = 3;
tb2.Layout.Column = 4;

end

%% Function to generate save filestem input
% Generates edit field (with label) allowing user to set FPS
%
% Arguments
%
% * uigridlayout |parent|: layout to add edit field in
%
% Returns uigridlayout composed of [uilabel, uieditfield("text")]
function gl = generateSaveFilestemElement(parent)
gl = uigridlayout(parent, [1 2]);
gl.Padding = [0 0 0 0];

lbl = uilabel(gl);
lbl.Text = "Filestem:"; % label
tb = uieditfield(gl, "text");
tb.Value = "results"; % default value

lbl.Layout.Column = 1;
tb.Layout.Column = 2;
end

%% Function to generate intensity bound input
% Generates two-value slider allowing user to set lower and upper bounds on
% image intensity
%
% Arguments
%
% * uigridlayout |gl|: layout to add slider in
%
% Returns uislider
function slider = generateThresholdSlider(gl)
slider = uislider(gl, "range");

% set major and minor tick locations
maxIntensity = 2^16; % maximum intensity for TIF image
slider.Limits = [0 maxIntensity];
slider.Value = [0 maxIntensity];
slider.MinorTicks = 0:2^11:maxIntensity;
slider.MajorTicks = 0:2^14:maxIntensity;

% format major tick labels
majorTicks = slider.MajorTicks;
tickCount = numel(majorTicks);
majorTickLabels = strings(1, tickCount);
for index = 1:tickCount
    majorTick = majorTicks(index);
    majorTickLabels(index) = sprintf("%d", majorTick);
end
slider.MajorTickLabels = majorTickLabels;
end

%% Miscellaneous helper functions
% Postprocess raw XY traces, i.e. |results|
function results = postprocessResults(results)
postprocessor = Postprocessor(results);
postprocessor.process();
results = postprocessor.getPostprocessedResults();
end