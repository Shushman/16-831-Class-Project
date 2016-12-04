function v = clamp(v)
    v(v>1) = 1;
    v(v<0) = 0;
end