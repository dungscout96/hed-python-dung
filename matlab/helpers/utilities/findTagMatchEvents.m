% This function looks through the events of a EEG strucutre and finds
% the events that contain a list of HED tags.
%
% Usage:
%
%   >> positions = findTagMatchEvents(events, tags);
%
% Inputs:
%
%   events       The dataset .event structure. The .event structure
%                is assumed to be tagged and has a .usertags field
%                containing the tags.
%
%   tags         A comma separated list of tags or a tag search string
%                consisting of tags to extract data epochs.
%                The tag search uses boolean operators (AND, OR, NOT) to
%                widen or narrow the search. Two tags separated by a comma
%                use the AND operator by default which will only return
%                events that contain both of the tags. The OR operator
%                looks for events that include either one or both tags
%                being specified. The NOT operator looks for events that
%                contain the first tag but not the second tag. To nest or
%                organize the search statements use square brackets.
%                Nesting will change the order in which the search
%                statements are evaluated. For example,
%                "/attribute/visual/color/green AND
%                [/item/2d shape/rectangle/square OR
%                /item/2d shape/ellipse/circle]"
%
% Outputs:
%
%   positions
%                A logical array containing the positions of the events
%                that found tag matches.
%
%
% Copyright (C) 2015 Jeremy Cockfield jeremy.cockfield@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

function positions = findTagMatchEvents(events, tags)
p = parseArguments();
positions = processEvents();

    function positions = processEvents()
        % Process the events and look for matches
        [uniqueHedStrings, ~, ids]= unique({events.usertags});
        positions = false(1,length(events));
        for a=1:length(uniqueHedStrings)
            [eventTags, eventNonGroupTags, eventGroupTags] = ...
                formatTags(uniqueHedStrings{a});
            str = createlogexp(length(eventGroupTags), p.tags);
            matchFound = evallogexp(str, eventTags, eventNonGroupTags, ...
                eventGroupTags);
            positions(ids == a) = matchFound;
        end
    end % processEvents
% readEEGEvents();

%     function [queryMap, matchedIndecies] = createQueryMap(matchedIndecies)
%         % This function creates a search query based on the number of
%         % event groups in the first event and stores it in a Map which is
%         % used to compute following event tag searches
%         [eventTags, eventNonGroupTags, eventGroupTags] = ...
%             formatTags(events(1).usertags);
%         str = createlogexp(length(eventGroupTags), p.tags);
%         queryMap = containers.Map('KeyType','double','ValueType','char');
%         queryMap(length(eventGroupTags)) = str;
%         matchFound = evallogexp(str, eventTags, eventNonGroupTags, ...
%             eventGroupTags);
%         if matchFound
%             matchedIndecies(1) = true;
%         end
%     end % createQueryMap
%
%     function [queryMap, matchedIndecies] = ...
%             findTagMatch(queryMap, matchedIndecies, index)
%         % This function searches for tags in the current event and returns
%         % true if any matches are found
%         [eventTags, ~, eventGroupTags] = ...
%             formatTags(events(index).usertags);
%         if queryMap.isKey(length(eventGroupTags))
%             str = queryMap(length(eventGroupTags));
%         else
%             str = createlogexp(length(eventGroupTags), p.tags);
%             queryMap(length(eventGroupTags)) = str;
%         end
%         matchedIndecies(index) = evallogexp(str, eventTags, ...
%             eventGroupTags);
%     end % findTagMatch
%
    function [tags, eventLevelTags, groupTags] = formatTags(tags)
        % Format the tags and puts them in a cellstr if they are in a
        % string
        tags = tagList.deStringify(tags);
        eventLevelTags = tags(cellfun(@ischar, tags));
        groupTags = tags(~cellfun(@ischar, tags));
        if ~iscellstr(tags)
            tags = [tags{:}];
        end
        tags =  tagList.getUnsortedCanonical(tags);
        eventLevelTags = tagList.getUnsortedCanonical(eventLevelTags);
        for a = 1:length(groupTags)
            groupTags{a} = tagList.getUnsortedCanonical(groupTags{a});
        end
    end % formatTags

    function p = parseArguments()
        % Parses the arguments passed in and returns the results
        p = inputParser();
        p.addRequired('events', @(x) ~isempty(x) && isstruct(x));
        p.addRequired('tags', @(x) ischar(x));
        p.parse(events, tags);
        p = p.Results;
    end % parseArguments

%     function readEEGEvents()
%         % This function reads EEG events in from a EEG structure
%         [queryMap, positions] = createQueryMap(positions);
%         for a = 2:length(events)
%             [queryMap, positions] = findTagMatch(queryMap, positions, a);
%         end
%     end % readEEGEvents

end % findevents