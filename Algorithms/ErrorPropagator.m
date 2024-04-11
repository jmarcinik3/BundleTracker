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
            x2 = obj2.Value;
            x = x1 + x2;
            xerr = sumError2(x1, x2, obj1.Error, obj2.Error);
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
            x2 = obj2.Value;
            x = x1 .* x2;
            xerr = multiplyError2(x1, x2, obj1.Error, obj2.Error);
            obj = ErrorPropagator(x, xerr);
        end
        function obj = mtimes(obj1, obj2)
            x1 = obj1.Value;
            x2 = obj2.Value;
            x = x1 * x2;

            xerr = zeros(size(x1, 1), size(x2, 2));
            a2 = (x1.').^2;
            da2 = (obj1.Error.').^2;
            b2 = x2.^2;
            db2 = obj2.Error.^2;
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
                    obj = obj1.(S(1).subs);
                    if numel(S) == 2
                        obj = obj(S(2).subs{:});
                    end
                case "()"
                    x = obj1.Value(S.subs{:});
                    xerr = obj1.Error(S.subs{:});
                    obj = ErrorPropagator(x, xerr);
            end
        end
        function obj = subsasgn(obj1, S, obj2)
            x = subsasgn(obj1.Value, S{:}, obj2.Value);
            xerr = subsasgn(obj1.Error, S{:}, obj2.Error);
            obj = ErrorPropagator(x, xerr);
        end
        function obj = subsindex(obj1, a)
            x = subsindex(obj1.Value, a);
            xerr = subsindex(obj1.Error, a);
            obj = ErrorPropagator(x, xerr);
        end
    end

    methods (Static)
        function x = getValue(objs)
            x = reshape([objs.Value], size(objs));
        end
        function x = getError(objs)
            x = reshape([objs.Error], size(objs));
        end

        function obj = scalarFunction(obj1, handle)
            x = obj1.Value;
            xerr = obj1.Error;
            y = handle(x);
            yerrLow = abs(y - handle(x-xerr));
            yerrHigh = abs(handle(x+xerr) - y);
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
end



function xerr = multiplyError2(x1, x2, xerr1, xerr2)
xerr = sqrt((x2.*xerr1).^2 + (x1.*xerr2).^2);
end

function xerr = divideError2(x1, x2, xerr1, xerr2)
x2i = abs(1 ./ x2);
xerr = x2i .* sqrt(xerr1.^2 + (x1.*x2i.*xerr2).^2);
end

function xerr = sumError2(~, ~, xerr1, xerr2)
xerr = sqrt(xerr1.^2 + xerr2.^2);
end
