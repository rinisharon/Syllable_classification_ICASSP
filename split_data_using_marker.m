function [ data_cell ] = split_data_using_marker( filename, start_marker, end_marker, skip_samples )
    data_struct = load(filename);
    data_fields = fieldnames(data_struct);
    marker_struct = data_struct.evt_ECI_TCPIP_55513;
    marker_entries_size = size(marker_struct, 2);
    current_data = data_struct.(data_fields{1});

    current_data = current_data(1 : 128, :);
    current_data = remove_dc_shift_ex(current_data, skip_samples);
    
    data_cell = cell(0);
    data_index = 1;
    
    order=[];
    for i =  2 :  marker_entries_size
        str = marker_struct{1, i};
        prev_str = marker_struct{1, i - 1};
        
        %if (strcmp(str, end_marker) && strcmp(prev_str, start_marker))
        if (contains(str, end_marker) && contains(prev_str, start_marker))
            %disp(str(2));
            %order(i-1)=str(2);
            start_index = marker_struct{4, i-1};     
            end_index = marker_struct{4, i};
            
            data_cell{data_index, 1} = current_data(:, start_index:end_index);
            data_index = data_index + 1;
        end
    end
end

