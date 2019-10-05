return {
    map = function (t, f, ...)
        local nt = {}
        for k,v in ipairs(t) do
            if type(f) == 'string' then
                if v[f] then nt[k] = v[f](v, ...) end
            else
                nt[k] = f(v, ...)
            end
        end
        return nt
    end,

    foreach = function (t, f, ...)
        for k,v in ipairs(t) do
            if type(f) == 'string' then
                v[f](v, ...)
            else
                f(v, ...)
            end
        end
    end,

    clamp = function (x, min, max)
        return math.max(min, math.min(max, x))
    end,

    copyTable = function (t)
        local nt = {}
        for k,v in pairs(t) do
            nt[k] = v
        end
        return nt
    end,

    Set = Class{
        init = function (self)
            self.data = {}
        end,
    
        has = function (self, value)
            return self.data[value]
        end,
    
        add = function (self, value)
            self.data[value] = true
        end,
    
        remove = function (self, value)
            self.data[value] = nil
        end,

        toTable = function (self)
            local t = {}
            for key in pairs(self.data) do
                table.insert(t, key)
            end
            return t
        end,
    },

    hover = function(x, y, l, t, r, b)
        return l <= x and x <= r and t <= y and y <= b
    end,
}