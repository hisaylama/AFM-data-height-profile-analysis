classdef HeightProfileApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        LoadButton           matlab.ui.control.Button
        PlotButton           matlab.ui.control.Button
        PlotButtonLine       matlab.ui.control.Button
        BaselineButton       matlab.ui.control.Button
        GaussianFitButton    matlab.ui.control.Button
        SaveButton           matlab.ui.control.Button
        UIAxes               matlab.ui.control.UIAxes
        X1EditFieldLabel     matlab.ui.control.Label  % Label for X1
        X1EditField          matlab.ui.control.NumericEditField
        Y1EditFieldLabel     matlab.ui.control.Label  % Label for Y1
        Y1EditField          matlab.ui.control.NumericEditField
        X2EditFieldLabel     matlab.ui.control.Label  % Label for X2
        X2EditField          matlab.ui.control.NumericEditField
        Y2EditFieldLabel     matlab.ui.control.Label  % Label for Y2
        Y2EditField          matlab.ui.control.NumericEditField
        HeightData           double % stores the height data
        XData                double % stores the X coordinates
        ZData                double % stores the Z (height) data
        ProfileData          double % stores the line profile data
        ShiftedProfileData   double % stores the corrected profile
        FWHMData             double % stores FWHM values
        Peak2peak            double %store the height
        AspectRatioData      double % stores aspect ratio values
        MeanAspectRatio      double % stores mean aspect ratio
        ResultsTable         matlab.ui.control.Table % Table for results display
    end
%Depending on the size of AFM image, users has to change the values of xunit, xlim, ylim and (250/56) factors
%Assumption: base width = 2x FWHM of gaussian
    methods (Access = private)

        % Load Data Button pressed function
        function LoadButtonPushed(app, ~)
            [file, path] = uigetfile('*.txt', 'Select the Data File');
            if file
                fullfile = strcat(path, file);
                app.HeightData = importdata(fullfile); % Load the file
                [length_x, length_y] = size(app.HeightData);
                [app.XData, YData] = meshgrid(1:length_x, 1:length_y);
                
                % Adjust height data for better visibility
                app.ZData = app.HeightData + max(app.HeightData(:));
                
                % Plot the surface
                surf(app.UIAxes, app.XData, YData, app.ZData, 'EdgeColor', 'none');
                view(app.UIAxes, [0, 90]);
                colormap(app.UIAxes, 'jet');
                colorbar(app.UIAxes);
            end
        end

        % Plot Profile Button pressed function
         function PlotButtonLinePushed(app, ~)

            [length_x, length_y] = size(app.HeightData);
            [app.XData, YData] = meshgrid(1:length_x, 1:length_y);
            % Retrieve the values from the editable fields
            x1 = app.X1EditField.Value;
            y1 = app.Y1EditField.Value;
            x2 = app.X2EditField.Value;
            y2 = app.Y2EditField.Value;

            % Plot the surface with line 
            figure;
            surf(app.XData, YData, app.ZData, 'EdgeColor', 'none');
            view([0, 90]);
            colormap('jet');
            colorbar;
            hold("on")
            line([x1, x2], [y1, y2], [max(app.ZData(:)), max(app.ZData(:))], 'Color', 'red', 'LineWidth', 2);
            xlabel('x (pixel)');
            ylabel('y (pixel)');
            title('See the location of line profile');
            set(gca, 'FontName', 'Times', 'FontSize', 15);
            hold("off")
            grid off
            xlim([0,256])
            ylim([0,256])

            uialert(app.UIFigure, 'Check the location of line profile!', 'Success');
         end

         % Plot Profile Button pressed function
        function PlotButtonPushed(app, ~)
            % Retrieve the values from the editable fields
            x1 = app.X1EditField.Value;
            y1 = app.Y1EditField.Value;
            x2 = app.X2EditField.Value;
            y2 = app.Y2EditField.Value;

            % Extract line profile based on user-defined coordinates
            app.ProfileData = improfile(app.ZData, [x1, x2], [y1, y2]);
            xunit = (50/256).*1e-6; % conversion of x, y in meters

            % Plot the profile
            figure;
            plot(((x1:x2)-x1).*xunit, app.ProfileData, 'r-', 'LineWidth', 1.2);         
            xlabel('Distance (m)');
            ylabel('Height (m)');
            title('Height profile');
            set(gca, 'FontName', 'Times', 'FontSize', 15);
        end


        % Baseline Correction Button pressed function
        function BaselineButtonPushed(app, ~)
            x = (app.X1EditField.Value:app.X2EditField.Value)-app.X1EditField.Value;
            y = app.ProfileData';

            % Detect local minima
            TF = islocalmin(y);
            xlst = x(TF);
            ylst = y(TF);

            % Shift local minima
            ylst_new = zeros(size(ylst));
            for jj = 1:length(xlst)-1
                ylst_new(jj) = abs(ylst(jj+1) - ylst(jj)) / 2;
            end
            ylst_new(end) = ylst(end);
            shifts = ylst_new - ylst;
            y_new = y;
            for kk = 1:length(xlst) - 1
                shift = shifts(kk);
                idx_range = (x >= xlst(kk)) & (x < xlst(kk + 1));
                y_new(idx_range) = y_new(idx_range) + shift;
            end
            shift = shifts(end);
            y_new(x >= xlst(end)) = y_new(x >= xlst(end)) + shift;

            app.ShiftedProfileData = y_new;
            
            xunit = (50/256).*1e-6; % conversion of x, y in meters
            % Plot original and shifted profile
            figure;
            plot(x.*xunit, y, 'b-', 'LineWidth', 1.2);
            hold on;
            plot(x.*xunit, y_new, 'g-', 'LineWidth', 1.2);
            xlabel('Distance (m)');
            ylabel('Height (m)');
            legend('Original profile', 'Shifted profile');
            title('Baseline corrected profile');
            set(gca, 'FontName', 'Times', 'FontSize', 15);
            hold off;
        end

        % Gaussian Fit Button pressed function
        function GaussianFitButtonPushed(app, ~)
            % Use shifted profile data for Gaussian fitting
            x = (app.X1EditField.Value:app.X2EditField.Value)-app.X1EditField.Value;
            y = app.ShiftedProfileData;

            [peaks, locs] = findpeaks(y, x);
            numPeaks = numel(locs);
            amplitudes = zeros(numPeaks-1, 1);
            Mu = zeros(numPeaks-1, 1);
            Sigma = zeros(numPeaks-1, 1);
            app.FWHMData = zeros(numPeaks-1, 1);
            app.AspectRatioData = zeros(numPeaks-1, 1);
            app.Peak2peak = zeros(numPeaks-1, 1);

            xunit = (50/256).*1e-6; % conversion of x, y in meters
            % Plot original data
            figure;
            plot(x.*xunit, y.*xunit, 'b.', 'MarkerSize', 10);
            hold on;

            % Fit Gaussian model to each peak
            for i = 1:numPeaks-1
                gaussModel = fittype(@(A, mu, sigma, x) A * exp(-(x - mu).^2 / (2 * sigma^2)), ...
                    'independent', 'x', 'dependent', 'y');
                windowSize = 20;
                startIndex = find(x >= locs(i) - windowSize, 1, 'first');
                endIndex = find(x <= locs(i) + windowSize, 1, 'last');
                xWindow = x(startIndex:endIndex);
                yWindow = y(startIndex:endIndex);

                fittedModel = fit(xWindow', yWindow', gaussModel, 'StartPoint', [peaks(i), locs(i), 1]);
                amplitudes(i) = fittedModel.A * (50/256);
                Mu(i) = fittedModel.mu * (50/256);
                Sigma(i) = fittedModel.sigma * (50/256);
                
                %Caclulate the height of the peaks
                app.Peak2peak(i) = fittedModel.A.*(1e6);

                % Calculate FWHM = additional (2)
                app.FWHMData(i) = 2 * sqrt(2 * log(2)) * fittedModel.sigma *(50/256); % FWHM formula
                % Calculate Aspect Ratio
                app.AspectRatioData(i) = fittedModel.A.*(1e6) ./(2*app.FWHMData(i)) ;

                xFit = linspace(locs(i) - windowSize, locs(i) + windowSize, 100);
                yFit = feval(fittedModel, xFit);
                plot(xFit.*xunit, yFit.*xunit, 'r-', 'LineWidth', 1.2);
            end
            hold off;
            xlabel('Distance (m)');
            ylabel('Height (m)');
            title('Gaussian fit of peaks');
            set(gca, 'FontName', 'Times', 'FontSize', 15);

            % Calculate and display mean aspect ratio
            app.MeanAspectRatio = mean(app.AspectRatioData);
            % Update Results Table
            createResultsTable(app);
        end

        % Function to create results table
        function createResultsTable(app)
            % Create a table for displaying results
            data = [2*app.FWHMData, app.Peak2peak ,app.AspectRatioData];
            columnNames = {'Base width (um)', 'Peak height (um)' ,'Aspect Ratio (A.R)'};
            app.ResultsTable.Data = data;
            app.ResultsTable.ColumnName = columnNames;
            app.ResultsTable.RowName = [];

            % Create a label for mean aspect ratio
            meanARLabel = uilabel(app.UIFigure, ...
                'Text', sprintf('Average - A.R = %.2f', app.MeanAspectRatio), ...
                'Position', [20, 50, 250, 30]);
        end

        % Save Table Button pressed function
        function SaveButtonPushed(app, ~)
            % Open file dialog to select the save location
            [file, path] = uiputfile('*.csv', 'Save Results Table As');
            if file
                % Construct full file name
                fullFileName = fullfile(path, file);

                % Get the data from the table
                data = app.ResultsTable.Data;

                % Save the data to a CSV file
                writetable(array2table(data), fullFileName, 'WriteVariableNames', false);

                % Optional: Display a message to confirm saving
                uialert(app.UIFigure, 'Results table saved successfully!', 'Success');
            end
        end
   end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [10 10 640 600];
            app.UIFigure.Name = 'Height visualisation app';

            % Create Load Button
            app.LoadButton = uibutton(app.UIFigure, 'push');
            app.LoadButton.Position = [20 550 120 30];
            app.LoadButton.Text = 'Load data (*.txt)';
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);

            % Create X1 Label and EditField
            app.X1EditFieldLabel = uilabel(app.UIFigure);
            app.X1EditFieldLabel.HorizontalAlignment = 'right';
            app.X1EditFieldLabel.Position = [20 480 50 22];
            app.X1EditFieldLabel.Text = 'X1 (pixel)';

            app.X1EditField = uieditfield(app.UIFigure, 'numeric');
            app.X1EditField.Position = [80 480 60 30];
            app.X1EditField.Value = 50;

            % Create Y1 Label and EditField
            app.Y1EditFieldLabel = uilabel(app.UIFigure);
            app.Y1EditFieldLabel.HorizontalAlignment = 'right';
            app.Y1EditFieldLabel.Position = [20 440 50 22];
            app.Y1EditFieldLabel.Text = 'Y1 (pixel)';

            app.Y1EditField = uieditfield(app.UIFigure, 'numeric');
            app.Y1EditField.Position = [80 440 60 30];
            app.Y1EditField.Value = 50;

            % Create X2 Label and EditField
            app.X2EditFieldLabel = uilabel(app.UIFigure);
            app.X2EditFieldLabel.HorizontalAlignment = 'right';
            app.X2EditFieldLabel.Position = [20 400 50 22];
            app.X2EditFieldLabel.Text = 'X2 (pixel)';

            app.X2EditField = uieditfield(app.UIFigure, 'numeric');
            app.X2EditField.Position = [80 400 60 30];
            app.X2EditField.Value = 230;

            % Create Y2 Label and EditField
            app.Y2EditFieldLabel = uilabel(app.UIFigure);
            app.Y2EditFieldLabel.HorizontalAlignment = 'right';
            app.Y2EditFieldLabel.Position = [20 360 50 22];
            app.Y2EditFieldLabel.Text = 'Y2 (pixel)';

            app.Y2EditField = uieditfield(app.UIFigure, 'numeric');
            app.Y2EditField.Position = [80 360 60 30];
            app.Y2EditField.Value = 50;

            %Visualize line overlayed surface plot
            app.PlotButtonLine = uibutton(app.UIFigure, 'push');
            app.PlotButtonLine.Position = [20 220 120 30];
            app.PlotButtonLine.Text = 'Check line loc.';
            app.PlotButtonLine.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonLinePushed, true);

            % Create Plot Button
            app.PlotButton = uibutton(app.UIFigure, 'push');
            app.PlotButton.Position = [20 180 120 30];
            app.PlotButton.Text = 'Draw line profile';
            app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);

            % Create Baseline Button
            app.BaselineButton = uibutton(app.UIFigure, 'push');
            app.BaselineButton.Position = [20 140 120 30];
            app.BaselineButton.Text = 'Baseline correction';
            app.BaselineButton.ButtonPushedFcn = createCallbackFcn(app, @BaselineButtonPushed, true);

            % Create Gaussian Fit Button
            app.GaussianFitButton = uibutton(app.UIFigure, 'push');
            app.GaussianFitButton.Position = [20 100 120 30];
            app.GaussianFitButton.Text = 'Fit peak (Gaussian)';
            app.GaussianFitButton.ButtonPushedFcn = createCallbackFcn(app, @GaussianFitButtonPushed, true);

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            app.UIAxes.Position = [150 220 450 350];
            app.UIAxes.XLabel.String = 'X (pixel)';
            app.UIAxes.YLabel.String = 'Y (pixel)';
            app.UIAxes.ZLabel.String = 'Z (m)';
            app.UIAxes.XLim = [0, 256];
            app.UIAxes.YLim = [0, 256];

            % Create Results Table
            app.ResultsTable = uitable(app.UIFigure);
            app.ResultsTable.Position = [180 10 400 150];
            app.ResultsTable.Data = [];
            app.ResultsTable.ColumnName = {'Base width (um)', 'Peak height (um)', 'Aspect Ratio (A.R)'};

            % Create Save Button
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.Position = [180 170 120 30];
            app.SaveButton.Text = 'Save Results';
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App initialization and construction
    methods (Access = public)

        % Construct app
        function app = HeightProfileApp
            % Create and configure components
            createComponents(app)

        end

        % Code that executes before app deletion
        function delete(app)
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
