classdef ErrorPropagator
    properties
        Value;
        Error;
    end

    methods
        function obj = ErrorPropagator(values, errors)
            if nargin == 0
                values = 0;
                errors = 0;
            end

            if size(values) ~= size(errors)
                error("Values must have same size as errors");
            elseif any(errors < 0)
                error("All errors must be non-negative");
            end

            obj.Value = values;
            obj.Error = errors;
        end
    end

    methods
        function obj = plus(obj1, obj2)
            x1 = obj1.Value;
            [x2, xerr2] = getValueError(obj2);
            x = x1 + x2;
            xerr = sumError2(x1, x2, obj1.Error, xerr2);
            obj = ErrorPropagator(x, xerr);
        end
        function obj = minus(obj1, obj2)
            obj = obj1.plus(-obj2);
        end
        function obj = uminus(obj1)
            obj = ErrorPropagator(-obj1.Value, obj1.Error);
        end
        function obj = uplus(obj1)
            obj = obj1;
        end

        function obj = times(obj1, obj2)
            x1 = obj1.Value;
            [x2, xerr2] = getValueError(obj2);
            x = x1 .* x2;
            xerr = multiplyError2(x1, x2, obj1.Error, xerr2);
            obj = ErrorPropagator(x, xerr);
        end
        function obj = mtimes(obj1, obj2)
            x1 = obj1.Value;
            [x2, xerr2] = getValueError(obj2);
            x = x1 * x2;

            xerr = zeros(size(x1, 1), size(x2, 2));
            a2 = (x1.').^2;
            da2 = (obj1.Error.').^2;
            b2 = x2.^2;
            db2 = xerr2.^2;
            for i = 1:size(x1, 1)
                c2 = b2 .* da2(:, i) + a2(:, i) .* db2;
                xerr(i, :) = sqrt(sum(c2, 1));
            end

            % slow but very reliable, brute-force code
            % xvecs(size(x1, 1), size(x2, 2), size(x1, 2)) = ErrorPropagator;
            % for i = 1:size(x1, 1)
            %     for j = 1:size(x2, 2)
            %         for k = 1:size(x1, 2)
            %             a = ErrorPropagator(obj1.Value(i,k), obj1.Error(i,k));
            %             b = ErrorPropagator(obj2.Value(k,j), obj2.Error(k,j));
            %             xvecs(i, j, k) = a .* b;
            %         end
            %     end
            % end
            % xvecs = ErrorPropagator.sum(xvecs, 3);
            % xerrsvec = xvecs.Error;
            % disp(sum(xerr - xerrsvec, "all"));

            obj = ErrorPropagator(x, xerr);
        end
        function obj = power(obj1, n)
            x1 = obj1.Value;
            x = x1 .^ n;
            xerr = powerError(x1, obj1.Error, n);
            obj = ErrorPropagator(x, xerr);
        end
            
        function obj = rdivide(obj1, obj2)
            x1 = obj1.Value;
            x2 = obj2.Value;
            x = x1 ./ x2;
            xerr = divideError2(x1, x2, obj1.Error, obj2.Error);
            obj = ErrorPropagator(x, xerr);
        end
        function obj = ldivide(obj1, obj2)
            obj = rdivide(obj2, obj1);
        end

        function obj = lt(obj1, obj2)
            difference = obj1 - obj2;
            obj = (obj1 ~= obj2) & (difference.Value < 0);
        end
        function obj = gt(obj1, obj2)
            difference = obj1 - obj2;
            obj = (obj1 ~= obj2) & (difference.Value > 0);
        end
        function obj = le(obj1, obj2)
            obj = (obj1 < obj2) | (obj1 == obj2);
        end
        function obj = ge(obj1, obj2)
            obj = (obj1 > obj2) | (obj1 == obj2);
        end
        function obj = ne(obj1, obj2)
            obj = ~(obj1 == obj2);
        end
        function obj = eq(obj1, obj2)
            difference = obj1 - obj2;
            obj = abs(difference.Value) <= difference.Error;
        end
        function obj = and(obj1, obj2)
            obj = (obj1 == 0) & (obj2 == 0);
        end
        function obj = or(obj1, obj2)
            obj = (obj1 == 0) | (obj2 == 0);
        end
        function obj = not(obj1)
            obj = ~(obj1 == 0);
        end

        function obj = ctranspose(obj1)
            obj = ErrorPropagator(obj1.Value', obj1.Error');
        end
        function obj = transpose(obj1)
            obj = ErrorPropagator(obj1.Value.', obj1.Error.');
        end
        function obj = horzcat(obj1, obj2)
            x = horzcat(obj1.Value, obj2.Value);
            xerr = horzcat(obj1.Error, obj2.Error);
            obj = ErrorPropagator(x, xerr);
        end
        function obj = vertcat(obj1, obj2)
            x = vertcat(obj1.Value, obj2.Value);
            xerr = vertcat(obj1.Error, obj2.Error);
            obj = ErrorPropagator(x, xerr);
        end
        function obj = subsref(obj1, S)
            switch string(S(1).type)
                case "."
                    obj = getFieldSubset(obj1, S);
                case "()"
                    obj = getSubset(obj1, S);
            end
        end
        function obj = subsasgn(obj1, S, obj2)
            obj = subsasgn(obj1, S, obj2);
        end
        function obj = subsindex(obj1, a)
            obj = subsindex(obj1, a);
        end
    end

    methods (Static)
        function x = getValue(objs)
            x = reshape([objs.Value], size(objs));
        end
        function x = getError(objs)
            x = reshape([objs.Error], size(objs));
        end
        function obj = scalarFunction(obj1, handle, varargin)
            x = obj1.Value;
            xerr = obj1.Error;
            y = handle(x, varargin{:});
            yerrLow = abs(y - handle(x-xerr,varargin{:}));
            yerrHigh = abs(handle(x+xerr,varargin{:}) - y);
            yerr = 0.5 * (yerrLow + yerrHigh);
            obj = ErrorPropagator(y, yerr);
        end

        function obj = sum(objs, varargin)
            x = ErrorPropagator.getValue(objs);
            xerr = ErrorPropagator.getError(objs);
            y = sum(x, varargin{:});
            yerr = sqrt(sum(xerr.^2, varargin{:}));
            obj = ErrorPropagator(y, yerr);
        end
    end

    % Helper methods for common functions
    methods
        function obj = sin(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @sin);
        end
        function obj = sinc(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @sinc);
        end
        function obj = cos(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @cos);
        end
        function obj = tan(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @tan);
        end
        function obj = cot(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @cot);
        end
        function obj = sec(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @sec);
        end
        function obj = csc(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @csc);
        end
        function obj = asin(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @asin);
        end
        function obj = acos(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @acos);
        end
        function obj = atan(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @atan);
        end
        function obj = acot(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @acot);
        end
        function obj = asec(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @asec);
        end
        function obj = acsc(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @acsc);
        end
        function obj = sinh(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @sinh);
        end
        function obj = cosh(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @cosh);
        end
        function obj = tanh(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @tanh);
        end
        function obj = coth(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @coth);
        end
        function obj = sech(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @sech);
        end
        function obj = csch(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @csch);
        end
        function obj = asinh(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @asinh);
        end
        function obj = acosh(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @acosh);
        end
        function obj = atanh(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @atanh);
        end
        function obj = acoth(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @acoth);
        end
        function obj = asech(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @asech);
        end
        function obj = acsch(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @acsch);
        end
        function obj = log(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @log);
        end
        function obj = log10(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @log10);
        end
        function obj = log2(obj1)
            obj = ErrorPropagator.scalarFunction(obj1, @log2);
        end
    end
end



function xerr = multiplyError2(x1, x2, xerr1, xerr2)
xerr = sqrt((x2.*xerr1).^2 + (x1.*xerr2).^2);
end

function xerr = divideError2(x1, x2, xerr1, xerr2)
x2i = 1 ./ abs(x2);
xerr = x2i .* sqrt(xerr1.^2 + (x1.*x2i.*xerr2).^2);
end

function xerr = powerError(x1, xerr1, n)
xerr = sqrt(n) * xerr1 .* abs(x1).^(n-1);
end

function xerr = sumError2(~, ~, xerr1, xerr2)
xerr = sqrt(xerr1.^2 + xerr2.^2);
end

function [x, xerr] = getValueError(obj)
if isa(obj, "ErrorPropagator")
    x = obj.Value;
    xerr = obj.Error;
else
    x = obj;
    xerr = 0;
end
end

function fieldname = checkField(obj, S)
fieldname = S(1).subs;
if ~ismember(fieldname, fieldnames(obj))
    msg = sptrinf( ...
        "%s is not a valid fieldname for %s.", ...
        fieldname, ...
        class(obj) ...
        );
    error(msg);
end
end

function obj = getFieldSubset(obj1, S)
fieldname = checkField(obj1, S);
obj = obj1.(fieldname);
if numel(S) == 2
    obj = obj(S(2).subs{:});
end
end

function obj = getSubset(obj1, S)
x = obj1.Value(S.subs{:});
xerr = obj1.Error(S.subs{:});
obj = ErrorPropagator(x, xerr);
end

function obj = subsindex(obj1, a)
x = subsindex(obj1.Value, a);
xerr = subsindex(obj1.Error, a);
obj = ErrorPropagator(x, xerr);
end

function obj = subsasgn(obj1, S, obj2)
x = subsasgn(obj1.Value, S{:}, obj2.Value);
xerr = subsasgn(obj1.Error, S{:}, obj2.Error);
obj = ErrorPropagator(x, xerr);
end
