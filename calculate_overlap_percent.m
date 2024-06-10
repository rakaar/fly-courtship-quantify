function overlapPercentage = calculate_overlap_percent(segment1, segment2)
    % Identify overlapping elements (element-wise AND operation)
    overlap = segment1 & segment2;
    
    % Count overlapping elements
    numberOfOverlappingElements = sum(overlap(:));
    
    % Calculate total elements in the first segment
    totalElementsSegment1 = sum(segment1(:));
    
    % Compute overlap percentage
    overlapPercentage = (numberOfOverlappingElements / totalElementsSegment1) * 100;
end
