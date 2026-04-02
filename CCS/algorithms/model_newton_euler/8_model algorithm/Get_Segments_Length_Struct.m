function segments_length = Get_Segments_Length_Struct(kinectstream)
kinect_cell_arrays = Kinect_Azure_Struct_To_Array(kinectstream);
segments_length = Get_Segments_Length(kinect_cell_arrays);
end