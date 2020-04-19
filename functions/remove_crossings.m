function S = remove_crossings(S)
% author abda@dtu.dk, 2014

S1 = [S;S(1,:)];
n1 = size(S1,1);
n = n1-1;

for i = 1:n1-3
    for j = i+2:n1-1
        if ( is_crossing(S1(i,:), S1(i+1,:), S1(j,:), S1(j+1,:)) )
            f = i+1;
            t = j;
            if ( j-i > n/2 )
                f = j+1;
                t = i+n;
            end
            while ( f < t )
                idF = mod(f,n);
                if ( idF == 0 )
                    idF = n;
                end
                f = f + 1;
                
                idT = mod(t,n);
                if ( idT == 0 )
                    idT = n;
                end
                t = t - 1;
                tmp = S1(idF,:);
                S1(idF,:) = S1(idT,:);
                S1(idT,:) = tmp;
            
            end
            S1(end,:) = S1(1,:);
        end
    end
end

S = S1(1:end-1,:);

function is_cross = is_crossing(p1, p2, p3, p4)

is_cross = false;

if ( (p1(1) - p2(1))*(p3(2) - p4(2)) - (p1(2) - p2(2))*(p3(1) - p4(1)) ~= 0 )
    d21 = p2 - p1;
    d43 = p4 - p3;
    d31 = p3 - p1;
    
    if ( d21(1) ~= 0 && d21(2) ~= 0 )
        A = d43(1)/d21(1) - d43(2)/d21(2);
        B = d31(2)/d21(2) - d31(1)/d21(1);
        
        if ( A ~= 0 )
            u = B/A;
            if ( d21(1) > 0 )
                t = (d43(1)*u + d31(1))/d21(1);
            else
                t = (d43(2)*u + d31(2))/d21(2);
            end

            if ( u > 0 && u < 1 && t > 0 && t < 1 )
                is_cross = true;
            end
        end
    end
end











