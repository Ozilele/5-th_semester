module Functions

# delta, epsilon - dokładności obliczeń
# return (r, v, it, err)
function mbisekcji(f::Function, a::Float64, b::Float64, delta::Float64, epsilon::Float64)
    err = 0
    it = 0
    u = f(a)
    v = f(b)
    e = b - a
    if(sign(u) == sign(v)) 
        err = 1
        return (0, 0, it, err)
    end

    while true
        e = e / 2
        c = a + e
        w = f(c)
        it += 1

        if(abs(e) < delta || abs(w) < epsilon)
            err = 0
            return (c, w, it, err)
        end

        if(sign(w) != sign(u)) # root of the equation is in [a, c]
            b = c
            v = w
        else # root of the equation is in [b, c]
            a = c
            u = w
        end
    end
end

# delta, epsilon - dokładności obliczeń 
# maxit - maksymalna dopuszczalna liczba iteracji
# return (r, v, it, err)
function mstycznych(f::Function, pf::Function, x0::Float64, delta::Float64, epsilon::Float64, maxit::Int)
    v = f(x0)
    if abs(v) < epsilon
        return (x0, v, 0, 0) 
    end

    if abs(pf(x0)) < epsilon
        return (0, 0, 0, 2) # derivative bliska zeru
    end

    for k in 1:maxit
        x1 = x0 - v / pf(x0)
        v = f(x1)
        if(abs(v) < epsilon || abs(x1 - x0) < delta)
            return (x1, v, k, 0)
        end
        x0 = x1
    end
    return (0, 0, 0, 1)
end

# f - funkcja f(x) zadana jako anonimowa funkcja
# x0, x1 - przyblizenia początkowe
# delta, epsilon - dokładności obliczeń
# maxit - maksymalna dopuszczalna liczba iteracji
function msiecznych(f::Function, x0::Float64, x1::Float64, delta::Float64, epsilon::Float64, maxit::Int)
    fa = f(x0)
    fb = f(x1)
    for k in 1:maxit
        if(abs(fa) > abs(fb))
            tmp = x0
            tmp_f = fa
            x0 = x1
            x1 = tmp
            fa = fb
            fb = tmp_f
        end
        s = (x1 - x0) / (fb - fa)
        x1 = x0
        fb = fa
        x0 = x0 - (fa * s)
        fa = f(x0)
        if(abs(x1 - x0) < delta || abs(fa) < epsilon)
            return (x0, fa, k, 0)
        end
    end
    return (0, 0, 0, 1)
end

end