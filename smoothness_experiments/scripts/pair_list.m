
function ar_list_final = pair_list(list_1,list_2)

% pair_list(list_1, list_2)

% Creates a random list of combinations of items in list_1 and list_2,
% in both orderings, so that all consecutive pairs share one item. 

% For example,
% pair_list(1:2, 3:4) = 
%     2     4
%     3     2
%     1     3
%     4     1
%     4     2
%     1     4
%     3     1
%     2     3


    %Keep track of the number of bad consecutives, by initializing it high
    cur_switch = 100;
    %This loop tries different permutations until it finds a good one
    for i = 1:20
    combo_list = combvec(list_1, list_2)';
    combo_list = [combo_list; [combo_list(:,2), combo_list(:,1)]];
    combo_list = randomPermute(combo_list);

    ar_list = [];
    current_row = combo_list(1, :);
    combo_list = combo_list(2:end, :);
    ind = 1;
    ar_list = [ar_list; current_row];
    switches = 0;
    while size(combo_list, 1)> 0
        [row, combo_list, is_switch] = find_next_element(current_row, combo_list);
        switches = switches+is_switch;
        ar_list = [ar_list; row];
        current_row = row;
    end

    if switches < cur_switch
        cur_switch = switches;
        ar_list_final = ar_list;
    end
    if switches==0
        break
    end
    end
    cur_switch
end


function r = randomPermute(mat)
   r = mat(randperm(length(mat)),:);
end	



function b = share_element(p1,p2)
    if ( p1(1)==p2(1) || p1(1)==p2(2) || p1(2)==p2(2) || p1(2)==p2(1) )
        b=1;
    else
        b=0;
    end
end


function [row, combo_list_new, reset] = find_next_element(current_row, combo_list)
     found=0;
     reset=0;
     for i=1:size(combo_list, 1)
		combo_row = combo_list(i,:);
		if share_element(combo_row, current_row)
			row = combo_row;
            found=1;
			break;
        end
    end
    if ~found
        reset = 1;
        i=1;
    	row = combo_list(i,:);
    end
	combo_list_new = combo_list([1:i-1, i+1:end],:);
end

