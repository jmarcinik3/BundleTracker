classdef TrackingGui < handle
    properties (Access = private, Constant)
        queueColor = "red";
        workingColor = "yellow";
        finishedColor = "green";
    end

    properties (Access = private)
        intensityThresholds;
        rawImage = [];
        imageExtension = ".tif";

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

        trackButton;
        saveImageButton;
        saveFilestemElement;
        filepather; % object to find ".tif" image filepaths
    end

    methods
        function obj = TrackingGui(varargin)
            p = inputParser;
            addOptional(p, "Filepath", "");
            addOptional(p, "EnableZoom", true);
            parse(p, varargin{:});
            filepath = p.Results.Filepath;
            enableZoom = p.Results.EnableZoom;

            fig = uifigure;
            fig.Name = "Hair-Bundle Tracking";
            gl = uigridlayout(fig, [10 2]);
            obj.figure = fig;
            obj.gridLayout = gl;

            directorySelector = DirectorySelector(gl, fig);
            directoryText = directorySelector.getFilepathDisplay();
            directoryText.ValueChangedFcn = @(src, ev) obj.directoryUpdated();
            directorySelector.setDirectory(filepath);
            obj.directorySelector = directorySelector;

            obj.bundleDisplay = BundleDisplay( ...
                gl, ...
                "EnableZoom", enableZoom ...
                );
            obj.rawImage = [];

            obj.trackingSelection = generateTrackingSelection(gl);
            obj.kinociliumLocation = KinociliumLocation(gl);
            obj.scaleFactorInputElement = generateScaleFactorElement(gl);
            obj.fpsInputElement = generateFpsInputElement(gl);
            obj.saveFilestemElement = generateSaveFilestemElement(gl);

            thresholdSlider = generateThresholdSlider(gl);
            thresholdSlider.ValueChangingFcn = @(src, ev) obj.thresholdChanging(src, ev);
            obj.intensityThresholds = thresholdSlider.Value;
            obj.thresholdSlider = thresholdSlider;

            invertCheckbox = generateInvertCheckbox(gl);
            invertCheckbox.ValueChangedFcn = @(src, ev) obj.updateBundleDisplay();
            obj.invertCheckbox = invertCheckbox;

            trackButton = generateTrackButton(gl);
            trackButton.ButtonPushedFcn = @(src, ev) obj.startTracking();
            obj.trackButton = trackButton;

            saveImageButton = generateSaveImageButton(gl);
            saveImageButton.ButtonPushedFcn = @(src, ev) obj.saveBundleDisplay();
            obj.saveImageButton = saveImageButton;

            obj.directoryUpdated();
            layoutElements(obj);
        end

        function processor = getPreprocessor(obj)
            thresholds = obj.getThresholds();
            invert = obj.getInvert();
            processor = Preprocessor(thresholds, invert);
            processor = @processor.get;
        end
    end

    %% Functions to retrieve state information
    methods
        % ...for preprocessing and bundle display
        function dir = getDirectory(obj)
            elem = obj.directorySelector;
            dir = elem.getDirectory();
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
            paths = obj.filepather.getFilepaths();
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
    methods
        % complex class objects for visual components
        function ax = getBundleDisplayAxis(obj)
            ax = obj.bundleDisplay.getAxis();
        end
        function elem = getDirectorySelectionElement(obj)
            elem = obj.directorySelector.gridLayout;
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
        function startTracking(obj)
            regions = obj.getTrackingRegions();
            count = numel(regions);

            if count == 0
                uialert(obj.figure, "No cells selected!", "Track")
            else
                colorRegions(regions, obj.queueColor);
                for index = 1:count
                    region = regions(index);
                    obj.trackAndSaveRegion(region);
                end
            end
        end

        function trackAndSaveRegion(obj, region)
            % retrieve relevant properties for tracking and processing
            trackingMode = obj.getTrackingSelection();
            preprocessor = obj.getPreprocessor();
            filepaths = obj.getFilepaths();
            thresholds = obj.getThresholds();
            isInverted = obj.getInvert();

            directoryPath = obj.getDirectory();
            kinoLocation = obj.getKinociliumLocation();
            scaleFactor = obj.getScaleFactor();
            scaleFactorError = obj.getScaleFactorError();
            fps = obj.getFps();

            colorRegions(region, obj.workingColor); % color region as in-process
            results = TrackRegion( ...
                region, filepaths, trackingMode, preprocessor ...
                ); % preprocess and track

            % add metadata to results
            results.DirectoryPath = directoryPath;
            results.Bounds = region.Position;
            results.IsInverted = isInverted;
            results.IntensityRange = thresholds;
            results.TrackingMode = trackingMode;
            results.KinociliumLocation = kinoLocation;
            results.ScaleFactor = scaleFactor;
            results.ScaleFactorError = scaleFactorError;
            results.Fps = fps;

            % postprocess signal
            postprocessor = Postprocessor(results);
            postprocessor.process();
            results = postprocessor.getPostprocessedResults();

            colorRegions(region, obj.finishedColor); % color region as finished

            filestem = obj.getSaveFilestem();
            filename = sprintf("%s%s.mat", filestem, region.Label);
            filepath = fullfile(directoryPath, filename);
            save(filepath, "results");
        end

        function saveBundleDisplay(obj)
            im = obj.rawImage;
            if numel(im) > 0
                directoryPath = obj.getDirectory();
                obj.bundleDisplay.save(directoryPath);
            else
                uialert(obj.figure, "No image imported!", "Save Image")
            end
        end

        function updateBundleDisplay(obj)
            im = obj.rawImage;
            if numel(im) > 0
                preprocessor = obj.getPreprocessor();
                im = preprocessor(im);
            end
            obj.bundleDisplay.update(im);
        end

        function directoryUpdated(obj)
            directory = obj.getDirectory();
            pather = ImageFilepath(directory, obj.imageExtension);
            count = pather.fileCount;

            if count >= 1
                filepath = pather.get(1);
                obj.rawImage = imread(filepath);
            else
                if isfolder(directory)
                    uialert(obj.figure, "No valid images found!", "Choose Directory")
                end
                obj.rawImage = [];
            end

            obj.bundleDisplay.clearRegions();
            obj.updateBundleDisplay();
            obj.filepather = pather;
            obj.updateFilecount();
        end

        function updateFilecount(obj)
            pather = obj.filepather;
            count = pather.fileCount;
            obj.directorySelector.setFilecount(count);
        end

        function thresholdChanging(obj, ~, event)
            obj.intensityThresholds = event.Value;
            obj.updateBundleDisplay();
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
%
% * Color |regions| by given |color|
function colorRegions(regions, color)
for index = 1:numel(regions)
    region = regions(index);
    region.Color = color;
end
end