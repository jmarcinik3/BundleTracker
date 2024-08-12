function [B, ndx, dbg] = natsort(A)
% Natural-order / alphanumeric sort the elements of a text array.
% Modified by Joseph Marcinik 2024
% (c) 2012-2024 Stephen Cobeldick
%
% Sorts text by character code and by number value. By default matches
% integer substrings and performs a case-insensitive ascending sort.
% Options to select the number format, sort order, case sensitivity, etc.
%

%% Input Wrangling %%
fnh = @(c)cellfun('isclass',c,'char') & cellfun('size',c,1)<2 & cellfun('ndims',c)<3;

if iscell(A)
    assert(all(fnh(A(:))),...
        'SC:natsort:A:CellInvalidContent',...
        'First input <A> cell array must contain only character row vectors.')
    C = A(:);
elseif ischar(A) % Convert char matrix:
    assert(ndims(A) < 3, ...
        'SC:natsort:A:CharNotMatrix', ...
        'First input <A> if character class must be a matrix.' ...
        ) %#ok<ISMAT>
    C = num2cell(A,2);
else % Convert string, categorical, datetime, enumeration, etc.:
    C = cellstr(A(:));
end

rgx = '\d+';
fmt = '%f';

txt = {};

% Character case:
tcm = [];
tcx = [];

%% Identify and Convert Numbers %%
[nbr, spl] = regexpi(C(:), rgx, 'match','split', txt{tcx});
if numel(nbr)
    V = [nbr{:}];
    if strcmp(fmt, '%b')
        V = regexprep(V, '^0[Bb]', '');
        vec = cellfun(@(s)pow2(numel(s)-1:-1:0)*sscanf(s, '%1d'),V);
    else
        vec = sscanf(strrep(sprintf(' %s','0',V{:}),',','.'),fmt);
        vec = vec(2:end); % SSCANF wrong data class bug (R2009b and R2010b)
    end
    assert(numel(vec)==numel(V),...
        'SC:natsort:sscanf:TooManyValues',...
        'The "%s" format must return one value for each input number.',fmt)
else
    vec = [];
end


%% Allocate Data %%
% Determine lengths:
nmx = numel(C);
lnn = cellfun('length', nbr);
lns = cellfun('length', spl);
mxs = max(lns);

% Allocate data:
idn = permute(bsxfun(@le,1:mxs,lnn),[2,1]); % TRANSPOSE lost class bug (R2013b)
ids = permute(bsxfun(@le,1:mxs,lns),[2,1]); % TRANSPOSE lost class bug (R2013b)
arn = zeros(mxs,nmx,class(vec));
ars =  cell(mxs,nmx);
ars(:) = {''};
ars(ids) = [spl{:}];
arn(idn) = vec;

%% Debugging Array %%
if nargout > 2
    dbg = cell(nmx,0);
    for k = 1:nmx
        V = spl{k};
        V(2,:) = [num2cell(arn(idn(:,k),k));{[]}];
        V(cellfun('isempty', V)) = [];
        dbg(k,1:numel(V)) = V;
    end
end

%% Sort Matrices %%
if ~any(tcm) % ignorecase
    ars = lower(ars);
end

[~,ndx] = sort(ars(mxs,:)); % ascend
for ii = mxs-1:-1:1
    [~,idx] = sort(arn(ii,ndx),'ascend');
    ndx = ndx(idx);
    [~,idx] = sort(idn(ii,ndx),'ascend');
    ndx = ndx(idx);
    [~,idx] = sort(ars(ii,ndx)); % ascend
    ndx = ndx(idx);
end

%% Outputs %%
if ischar(A)
    ndx = ndx(:);
    B = A(ndx,:);
else
    ndx = reshape(ndx,size(A));
    B = A(ndx);
end

end
