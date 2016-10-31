% Adds all of the components to the 'Find and Replace' tab in pop_tsv.
%
% Usage:
%
%   >>  replacetsv_input(tab)
%
% Input:
%
%   Required:
%
%   tab
%                    The 'Find and Replace' tab object in pop_tsv.
%
%
% Copyright (C) 2012-2016 Thomas Rognon tcrognon@gmail.com,
% Jeremy Cockfield jeremy.cockfield@gmail.com, and
% Kay Robbins kay.robbins@utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function replacetsv_input(tab)
replaceFile = '';
tsvFile = '';
outputFile = '';
columns = '2';
replaceCtrl = '';
tsvCtrl = '';
outputCtrl = '';
createPanel(tab);

    function browseOutputCallback(~, ~, replaceOutputCtrl, myTitle) 
        % Callback for 'Browse' button that sets the 'Output file' editbox
        defaultName = '';
        if ~isempty(tsvFile)
           [~, defaultName, ext] = fileparts(tsvFile); 
           defaultName = [defaultName '_update' ext];
        end
        [file, path] = uiputfile({'*.tsv', 'Tab-separated files(*.tsv)'}, ...
            myTitle, defaultName);
        if ischar(file) && ~isempty(file)
            outputFile = fullfile(path, file);
            set(replaceOutputCtrl, 'String', outputFile);
        end
    end % browseOutputCallback

    function browseReplaceCallback(~, ~, replaceTxtCtrl, myTitle) 
        % Callback for 'Browse' button that sets the 'Replace file'
        % editbox
        [tFile, tPath] = uigetfile({'*.tsv', 'Tab-separated files'; ...
            '*.txt', 'Text files'; '*.*', 'All files'}, myTitle);
        if tFile ~= 0
            replaceFile = fullfile(tPath, tFile);
            set(replaceTxtCtrl, 'String', replaceFile);
        end
    end % browseReplaceCallback

    function browseTSVCallback(~, ~, replaceTagCtrl, myTitle) 
        % Callback for 'Browse' button that sets the 'TSV input file'
        % editbox
        [tFile, tPath] = uigetfile({'*.tsv', 'Tab-separated files'; ...
            '*.txt', 'Text files'; '*.*', 'All files'}, myTitle);
        if tFile ~= 0
            tsvFile = fullfile(tPath, tFile);
            set(replaceTagCtrl, 'String', tsvFile);
        end
    end % browseTSVCallback

    function columnsCtrlCallback(src, ~) 
        % Callback for user directly editing the 'HED tag columns' editbox
        columns = str2num(get(src, 'String')); %#ok<ST2NM>
    end % columnsCtrlCallback

    function createButtons(panel)
        % Creates the buttons in the panel
        uicontrol('Parent', panel, ...
            'String', 'Browse', ...
            'Style', 'pushbutton', ...
            'TooltipString', ['Press to choose tab-separated input' ...
            ' file.'], ...
            'Units','normalized',...
            'Callback', {@browseTSVCallback, ...
            tsvCtrl, ...
            'Browse for HED replacement file'}, ...
            'Position', [0.775 0.9 0.2 0.1]);
        uicontrol('Parent', panel, ...
            'String', 'Browse', ...
            'Style', 'pushbutton', ...
            'TooltipString', 'Press to choose replacement file.', ...
            'Units','normalized',...
            'Callback', {@browseReplaceCallback, ...
            replaceCtrl, 'Browse for tag file'}, ...
            'Position', [0.775 0.75 0.2 0.1]);
        uicontrol('Parent', panel, ...
            'String', 'Browse', ...
            'Style', 'pushbutton', ...
            'TooltipString', ...
            'Press to choose output file.', ...
            'Units','normalized',...
            'Callback', {@browseOutputCallback, ...
            outputCtrl, ...
            'Browse for output file'}, ...
            'Position', [0.775 0.6 0.2 0.1]);
        uicontrol('Parent', panel, ...
            'String', 'Help', ...
            'Style', 'pushbutton', ...
            'TooltipString', ...
            'Press for instructions.', ...
            'Units','normalized',...
            'Callback', {@helpCallback}, ...
            'Position', [0.775 .45 0.2 0.1]);
        uicontrol('Parent', panel, ...
            'String', 'Update', ...
            'Style', 'pushbutton', ...
            'TooltipString', 'Press when finished', ...
            'Units','normalized',...
            'Callback', {@replaceCallback}, ...
            'Position', [0.775 0.025 0.2 0.1]);
    end % createButtons

    function createEditBoxes(panel)
        % Creates the edit boxes in the panel
        tsvCtrl = uicontrol('Parent', panel, ...
            'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'HorizontalAlignment', 'Left', ...
            'String', '', ...
            'TooltipString', ['A tab-separated input file containing' ...
            ' HED tags.'], ...
            'Units','normalized',...
            'Callback', {@tsvEditboxCallback}, ...
            'Position', [0.15 0.9 0.6 0.1]);
        replaceCtrl = uicontrol('Parent', panel, ...
            'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'HorizontalAlignment', 'Left', ...
            'Tag', 'validateHedXmlEdit', ...
            'String', '', ...
            'TooltipString', ['A tab-separated replacement file containing' ...
            ' tags that generated issues from a previous validation.' ...
            ' Any tags not in this file that generate issues will be' ...
            ' appended to first column.'], ...
            'Units','normalized',...
            'Callback', {@replaceEditboxCallback}, ...
            'Position', [0.15 0.75 0.6 0.1]);
        outputCtrl = uicontrol('Parent', panel, ...
            'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'HorizontalAlignment', 'Left', ...
            'String', '', ...
            'TooltipString', ['A tab-separated output file containing' ...
            ' the updated HED tags.'], ...
            'Units','normalized',...
            'Callback', {@outputEditboxCallback}, ...
            'Position', [0.15 0.6 0.6 0.1]);
        uicontrol('Parent', panel, ...
            'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'HorizontalAlignment', 'Left', ...
            'String', '2', ...
            'TooltipString', 'Output file', ...
            'Units','normalized',...
            'Callback', {@columnsCtrlCallback}, ...
            'Position', [0.15 0.45 0.6 0.1]);
    end % createEditBoxes

    function createLabels(panel)
        % Creates the labels in the panel
        uicontrol('parent', panel, ...
            'Style', 'Text', ...
            'Units', 'normalized', ...
            'String', 'TSV input file', ...
            'HorizontalAlignment', 'Left', ...
            'Position', [0 0.9 0.13 0.08]);
        uicontrol('parent', panel, ...
            'Style', 'Text', ...
            'Units', 'normalized', ...
            'String', 'Replace file', ...
            'HorizontalAlignment', 'Left', ...
            'Position', [0 0.75 0.12 0.08]);
        uicontrol('parent', panel, ...
            'Style', 'Text', ...
            'Units', 'normalized', ...
            'String', 'Output file', ...
            'HorizontalAlignment', 'Left', ...
            'Position', [0 0.6 0.12 0.08]);
        uicontrol('parent', panel, ...
            'Style', 'Text', ...
            'Units', 'normalized', ...
            'String', 'HED tag columns', ...
            'HorizontalAlignment', 'Left', ...
            'Position', [0 0.45 0.12 0.08]);
    end % createLabels

    function createPanel(tab)
        % Creates replace tags layout
        panel = uipanel('Parent', tab, ...
            'BorderType', 'none', ...
            'BackgroundColor', [.94 .94 .94], ...
            'FontSize', 12, ...
            'Position', [0 0 1 1]);
        createLabels(panel);
        createEditBoxes(panel);
        createButtons(panel);
    end % createPanel

    function outputEditboxCallback(src, ~) 
        % Callback for user directly editing the 'Output file' editbox
        outputFile = get(src, 'String');
    end % outputEditboxCallback

    function replaceCallback(~, ~) 
        % Callback for the tag validation button
        if isempty(replaceFile)
            errordlg('Replace file is empty');
        elseif isempty(tsvFile)
            errordlg('Tab-separated file is empty');
        elseif isempty(outputFile)
            errordlg('Output file is empty');
        elseif isempty(columns)
            errordlg('HED tag columns are empty');
        else
            wb = waitbar(.5,'Please wait...');
            try
                replacetsv(replaceFile, tsvFile, columns, ...
                    'OutputFile', outputFile);
                msgbox('Complete!');
            catch
                errordlg('Failed!');
            end
            close(wb);
        end
    end % replaceCallback

    function helpCallback(~, ~) 
        % Callback for the 'Help' button
        helpdlg(sprintf(['Find and replace the HED tags in a' ...
            ' tab-separated file.\n\n**Options*** \n\nTSV input file' ...
            ' - A tab-separated file containing HED tags in a single' ...
            ' column or multiple columns. \n\nReplace file - A two' ...
            ' column tab-separated file used to find and replace the' ...
            ' HED tags in the input file. The first column will be the' ...
            ' HED tags to find and the second column will be HED tags' ...
            ' that will replace them.\n\nOutput file - A tab-separated' ...
            ' file that is the result of the find and replace' ...
            ' performed on the input file.\n\nHED tag columns - The' ...
            ' columns in the tab-separated input file that contains' ...
            ' the HED tags. This is to be specified with a single' ...
            ' number or a comma separated list of numbers (e.g. 1' ...
            ' or 1,2,3,4). The default will be the second column.']), ...
            'Instructions');
    end % helpCallback

    function replaceEditboxCallback(src, ~)
        % Callback for user directly editing the 'Replace file' editbox
        replaceFile = get(src, 'String');
    end % replaceEditboxCallback

    function tsvEditboxCallback(src, ~) 
        % Callback for user directly editing the 'TSV input file' editbox
        tsvFile = get(src, 'String');
    end % tsvEditboxCallback

end % replacetsv_input