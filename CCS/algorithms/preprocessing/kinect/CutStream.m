function stream = CutStream(stream, idxs)
    names = fieldnames(stream);

    stream.wtime = stream.wtime(idxs);

    for i = 2:length(names)
        stream.(names{i}).x = stream.(names{i}).x(idxs);
        stream.(names{i}).y = stream.(names{i}).y(idxs);
        stream.(names{i}).z = stream.(names{i}).z(idxs);
    end

end