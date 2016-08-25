% Allows a user to selectively edit the tags using the CTagger GUI.
%
% Usage:
%
%   >>  fMap = editmaps(fMap)
%
%   >>  fMap = editmaps(fMap, 'key1', 'value1', ...)
%
% Input:
%
%   Required:
%
%   fMap
%                    A fieldMap object that stores all of the tags.
%
%   Optional (key/value):
%
%   'EditXml'
%                    If false (default), the HED XML cannot be modified
%                    using the CTagger GUI. If true, then the HED XML can
%                    be modified using the CTagger GUI.
%
%   'ExcludeFields'
%                    A cell array of field names in the .event substructure
%                    to ignore during the tagging process. By default the
%                    following subfields of the event structure are
%                    ignored: .latency, .epoch, .urevent, .hedtags, and
%                    .usertags. The user can over-ride these tags using
%                    this name-value parameter.
%
%   'Fields'
%                    A cell array of field names of the fields to include
%                    in the tagging. If this parameter is non-empty, only
%                    these fields are tagged.
%
%   'PreservePrefix'
%                    If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
%
% Copyright (C) Kay Robbins, Jeremy Cockfield, and Thomas Rognon, UTSA,
% 2011-2015, kay.robbins.utsa.edu jeremy.cockfield.utsa.edu
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

function [fMap, canceled] = editmaps(fMap, varargin)
% Check the input arguments for validity and initialize
p = parseArguments(fMap, varargin{:});
p = setDefaultParameters(p);
while (~p.canceled && p.k <= length(p.fields))
    fprintf('Tagging %s\n', p.fields{p.k});
    p.field = p.fields{p.k};
    p = editFieldTags(p);
end
canceled = p.canceled;

    function p = setDefaultParameters(p)
        % Set the default parameters for this function
        p.EditXml = p.EditXml;
        p.preservePrefix = p.PreservePrefix;
        p.initialDepth = 3;
        p.standAlone = false;
        p.useJSON = true;
        if ~isempty(p.Fields)
            p.fields = intersect(p.Fields, p.fMap.getFields(), 'stable');
        else
            p.fields = setdiff(p.fMap.getFields(), p.ExcludedFields);
        end
        p.canceled = false;
        p.k = 1;
        p.firstField = true;
    end % setDefaultParameters

    function p = editFieldTags(p)
        % Edit the tags in the current field using CTagger
        p.tMap = p.fMap.getMap(p.field);
        if isempty(p.tMap)
            p.k = p.k + 1;
            return;
        end
        p = executeCTagger(p);
        if p.loaded
            baseTags = fieldMap.loadFieldMap(char(p.loader.getFMapPath));
            p.fMap.merge(baseTags, 'Update', {}, p.fields);
            if p.loader.isStartOver()
                p.k = 1;
                p.firstField = true;
            end
        elseif p.loader.isSubmitted()
            updatefMap(p);
            if p.loader.isBack()
                p.k = p.k - 1;
            else
                p.k = p.k + 1;
            end
            p.firstField = p.k == 1;
        else
            p.canceled = true;
        end
    end % editFieldTags

    function p = executeCTagger(p)
        % Executes the CTagger GUI for the current field
        p = getCTaggerParameters(p);
        p.loader = javaObject('edu.utsa.tagger.TaggerLoader', ...
            p.xml, p.tValues, p.flags, p.eTitle, p.initialDepth);
        p = checkCTaggerStatus(p);
        while (~p.notified)
            pause(0.5);
            p = checkFMapSave(p);
            p = checkCTaggerStatus(p);
        end
        p.taggedList = p.loader.getXMLAndEvents();
    end % executeCTagger

    function p = checkCTaggerStatus(p)
        % Checks the status of the CTagger
        p.loaded = p.loader.fMapLoaded();
        p.saved = p.loader.fMapSaved();
        p.notified = p.loader.isNotified();
    end % checkCTaggerStatus

    function p = checkFMapSave(p)
        % Checks if an fieldMap has been saved
        if p.saved
            p.taggedList = p.loader.getXMLAndEvents();
            updatefMap(p);
            p.fMap.saveFieldMap(char(p.loader.getFMapPath), p.fMap);
            p.loader.setFMapSaved(false);
        end
    end % checkFMapSave

    function p = getCTaggerParameters(p)
        % Gets the parameters that are passed into the CTagger
        p.primaryField = p.tMap.getPrimary();
        p.tValues = strtrim(char(p.tMap.getJsonValues()));
        p.xml = p.fMap.getXml();
        p.flags = setCTaggerFlags(p);
        p.eTitle = ['Tagging ' p.field ' values'];
    end % getCTaggerParameters

    function flags = setCTaggerFlags(p)
        % Sets the flags parameter in CTagger
        flags = 1;
%         if p.useJSON
%             flags = bitor(flags,1);
%         end
        if p.preservePrefix
            flags = bitor(flags,2);
        end
        if p.EditXml
            flags = bitor(flags,8);
        end
        if p.standAlone
            flags = bitor(flags,16);
        end
        if p.primaryField
            flags = bitor(flags,32);
        end
        if p.firstField
            flags = bitor(flags,64);
        end
    end % setCTaggerFlags

    function updatefMap(p)
        % Updates the fMap tags if the current field is submitted in the
        % CTagger or a new fMap is loaded
        p.xml = strtrim(char(p.taggedList(1, :)));
        tValues = strtrim(char(p.taggedList(2, :)));
        tValues = tagMap.json2Values(tValues);
        p.fMap.removeMap(p.field);
        p.fMap.addValues(p.field, tValues, 'Primary', p.tMap.getPrimary());
        if p.EditXml
            p.fMap.setXml(strtrim(p.xml));
        end
    end % updatefMap

    function p = parseArguments(fMap, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('fMap', @(x) (~isempty(x) && isa(x, ...
            'fieldMap')));
        parser.addParamValue('Fields', {}, @iscellstr);
        parser.addParamValue('EditXml', false, @islogical);
        parser.addParamValue('ExcludedFields', {}, @iscellstr);
        parser.addParamValue('PreservePrefix', false, @islogical);
        parser.parse(fMap, varargin{:});
        p = parser.Results;
    end % parseArguments

end % editmaps