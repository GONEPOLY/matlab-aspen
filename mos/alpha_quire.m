function alpha = alpha_quire(num_n)
      n = num_n;
      a = fix(n/26);
      b = rem(n,26);
if a <1
    name = char(64+b);
else
    name = [char(64+a),char(64+b)];
end
  alpha = name;
end