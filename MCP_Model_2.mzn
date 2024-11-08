% Multi-Courier Optimization Problem
include "globals.mzn";

% Number of couriers
int: m_couriers_count;

% Number of items to be delivered
int: n_items_count;

% Maximum load each courier can carry
array[1..m_couriers_count] of int: l_max_loads;

% Weight of each item/package
array[1..n_items_count] of int: s_load_sizes;

% Distance matrix between locations
% 1..n_items_count+1 -> rows and columns
% +1 is for the base location
% e.g: if there are 5 items to deliver, the matrix will be 6x6 because it includes 
% the 5 delivery locations and 1 additional base location
% D_distances_matrix[i,j] represents the distance between location i and location j 
% if i == j, the distance is typically 0; to itself 
% If i != j, represents dist between two different locations
% D_distances_matrix[2, 3] = 3 means the distance between item 2 and item 3 is 3 units.
array[1..n_items_count+1, 1..n_items_count+1] of int: D_distances_matrix;

% The sequence in which each courier delivers the items
% 1..m_couriers_count: represents the num of couriers. Each row corresponds to the 
% delivery sequence of one courier
% 1..n_items_count+2: Represents the sequence of delivery stops for each courier, where: 
% n_items_count -> num of items to be delivered; +2 two extra stops from the depot
% var -> decision variable -> value will be determined by the solver during the optimisation process
% Each row specifies the sequence in which a courier visits the base and delivers items
% E.g: m_couriers_count = 2 (2 couriers), n_items_count = 3 (3 items to deliver)
% The array dimensions will be [1..2, 1..5] (because each courier has 3 items plus 2 stops for starting and ending at the base).
array[1..m_couriers_count, 1..n_items_count+2] of var int: order_of_delivery;

% Maximum distance covered by any courier
var int: maximum_distance;

% The total load each courier is transporting
% The array is indexed from 1..m_couriers_count, meaning it contains one entry for each courier
% Each entry courier_weight[i] represents the total weight carried by courier i during their deliveries
% sum(j in 2..n_items_count+1): Sums over all delivery stops; starts from 2 because j = 1 is the base
% where order_of_delivery[i,j] != n_items_count+1 -> ensures that only actual delivery stops where a courier delivers an item are included
% != n_items_count+1 -> refers to the base, exculdes stops at the base from the sum, so the courier isn't considered to be carrying an item at the base
% s_load_sizes[order_of_delivery[i,j]] -> This retrieves the weight of the item being delivered at the j-th stop by courier i
% s_load_sizes = [10, 5, 7];  % Weights of items 1, 2, and 3
% order_of_delivery = [
%    [4, 1, 2, 4],  % Courier 1 delivers item 1, then item 2, and returns to base
%    [4, 3, 4, 4]   % Courier 2 delivers item 3, and returns to base
% ] 
% For courier 1, weight = 10+5 = 15
array[1..m_couriers_count] of var int: courier_weight = 
  [sum(j in 2..n_items_count+1 where order_of_delivery[i,j] != n_items_count+1)(s_load_sizes[order_of_delivery[i,j]]) | i in 1..m_couriers_count];

% The total distance each courier travels
% array where each element represents the total distance traveled by each courier
% The array: 1..m_couriers_count, meaning it contains one entry for each courier.
% sum(j in 1..n_items_count+1) -> Sums the distances between consecutive locations for courier i, as they deliver items and return to the base
% D_distances_matrix[order_of_delivery[i,j], order_of_delivery[i,j+1]] -> this retrieves the distance between two consecutive stops for courier i
% order_of_delivery[i,j] gives the current stop, and order_of_delivery[i,j+1] gives the next stop.
% D_distances_matrix[order_of_delivery[i,j], order_of_delivery[i,j+1]] retrieves the distance between these two locations from the distance matrix
% sum the distances between consecutive stops
% the loop, where i iterates over the range from 1 to m_couriers_count
array[1..m_couriers_count] of var int: courier_distances = 
  [sum(j in 1..n_items_count+1)(D_distances_matrix[order_of_delivery[i,j], order_of_delivery[i,j+1]]) | i in 1..m_couriers_count];
  
% -------------------------------------------

% Ensure each item is delivered by exactly one courier
% Loop structure over 2 indices: 1. Loops over the couriers, 2. Loops over the stops in the delivery sequence of each courier
% For each combination of i and j, we are looking at the values in the order_of_delivery array to ensure that they are distinct.
% The condition order_of_delivery[i,j] != n_items_count+1 means we ignore the base locations in the order_of_delivery array and only apply the constraint to the delivery of actual items.
constraint
all_different(i in 1..m_couriers_count, j in 1..n_items_count+2 where order_of_delivery[i,j] != n_items_count+1)(order_of_delivery[i,j]);

% Ensure every item is assigned to a courier
% means that p iterates over all the items (from item 1 to item n_items_count
% exists, meaning that we are checking whether there is at least 1 courier i and 1 position j in the 
% courier's delivery sequence such that the item p appears in their order of delivery
% p == order_of_delivery[i,j] -> check if the item p is delivered by courier i at position j
constraint forall(p in 1..n_items_count)(
    exists(i in 1..m_couriers_count, j in 1..n_items_count+2)(p == order_of_delivery[i,j])
);

% Make sure the total weight carried by each courier does not exceed their maximum load capacity
% Loop through all the couriers 
% courier_weight[i] represents the total weight of the items being carried by courier i
% l_max_loads[i] is the maximum load capacity that courier i can carry.
constraint forall(i in 1..m_couriers_count)(
    courier_weight[i] <= l_max_loads[i]
);

% Ensure every item is delivered, and each courier starts and ends at the base location
% Loop through all the couriers
% order_of_delivery[i,1] = n_items_count+1 -> Ensures the 1st stop in the delivery seq for each
% courier i is the base location
% order_of_delivery[i, 1]: Refers to the first stop in the delivery sequence for courier i
% n_items_count + 1: Represents the base location (the depot or starting point)
% order_of_delivery[i, n_items_count+2]: Refers to the last stop in the delivery sequence for courier i
% why n_items_count + 2
% n_items_count: The number of items to be delivered, 1 additional stop for the start at the base
% one more to represent the return
constraint forall(i in 1..m_couriers_count)(
    order_of_delivery[i,1] = n_items_count+1 /\ order_of_delivery[i, n_items_count+2] = n_items_count+1
);

% Couriers should start with a delivery right after leaving the base
% check whether courier i has at least one valid delivery to make
% The variable j iterates over the delivery sequence positions, which includes all possible stops a courier can make
% The condition order_of_delivery[i,j] != n_items_count+1 -> checks if a courier i is assigned to deliver an item, i.e. they visit a location that is not the base
% -> (order_of_delivery[i, 2] != n_items_count+1): the right side of the implication states that the 
% second stop in the delivery sequence must not be the base
% This means that if courier i has at least one item to deliver, then their second stop must be an item delivery location, not a return to the base
% This constraint ensures that couriers don't return to the base prematurely
% If the constraint is violated, it would mean that the courier is returning to the base immediately after leaving without making any deliveries
constraint forall(i in 1..m_couriers_count)(
    exists(j in 1..n_items_count+1)(order_of_delivery[i,j] != n_items_count+1) -> (order_of_delivery[i, 2] != n_items_count+1)
);

% Remove this constraint if couriers are allowed to return to the base before taking additional deliveries
% Ensures that once a courier returns to the base, or stops delivering , they don't make any more deliveries afterwards
% for all couriers, for each delivery stop starting from the 2nd one
% (order_of_delivery[i,j] == n_items_count+1) -> checks whether the courier returns to the base, if the condition holds true it means that at stop j, the courier returns to the base
% -> not exists(k in j..n_items_count+1)(order_of_delivery[i,k] != n_items_count+1)
% This means that if courier i returns to the base at stop j, the following must hold true: there must not be any subsequent deliveries.
% exists(k in j..n_items_count+1) -> This checks whether there is any stop k where the courier makes a delivery
% (order_of_delivery[i,k] != n_items_count+1): This condition checks whether the courier makes any further deliveries after returning to the base.
% If the condition order_of_delivery[i,k] != n_items_count+1 holds true, it means that courier i is making a delivery at stop k after returning to the base.
% not exists: This part ensures that there cannot be any such stop k after j where the courier makes a delivery
constraint forall(i in 1..m_couriers_count)(
    forall(j in 2..n_items_count+1)((order_of_delivery[i,j] == n_items_count+1) -> not exists(k in j..n_items_count+1)(order_of_delivery[i,k] != n_items_count+1))
);

% If a courier has enough capacity, ensure they carry at least one item
% l_max_loads[c1] >= max(s_load_sizes): This condition checks whether courier c1 has enough capacity to carry the heaviest item.
% k runs over all possible delivery stops (k in 1..n_items_count+1)
% order_of_delivery[c1,k] != n_items_count+1: 
% This condition checks whether courier c1 is assigned to make a delivery to a location that is not the base. 
% If this is true, it means courier c1 has at least one item to deliver.
constraint forall(c1 in 1..m_couriers_count)(
  (l_max_loads[c1] >= max(s_load_sizes)) -> exists(k in 1..n_items_count+1)(order_of_delivery[c1,k] != n_items_count+1)
);

% Symmetry breaking 
% If two couriers have the same capacity, they are symmetric;
% we impose an order on the items they pick up to break this symmetry.
% used to reduce the num of equivalent solutions the solver needs to consider
% forall(c1 in 1..m_couriers_count, c2 in 1..m_couriers_count where c1 < c2): A loop that
% iterates over pairs of couriers; The condition c1 < c2 ensures that the comparison is only made once between each pair
% ((l_max_loads[c1] == l_max_loads[c2]): checks if courier c1 and courier c2 have the same maximum load capacity.
% lex_less(row(order_of_delivery, c1), row(order_of_delivery, c2)):
% This ensures that the delivery sequence of courier c1 is lexicographically less than the delivery sequence of courier c2 if they have the same capacity.
% row(order_of_delivery, c1) and row(order_of_delivery, c2) refer to the delivery sequences of courier c1 and courier c2, respectively
constraint symmetry_breaking_constraint(
    forall(c1 in 1..m_couriers_count, c2 in 1..m_couriers_count where c1 < c2)
     ((l_max_loads[c1] == l_max_loads[c2]) -> (lex_less(row(order_of_delivery, c1), row(order_of_delivery, c2))))
);

% If the maximum weight carried by two couriers is less than or equal to the smallest load capacity,
% their routes are interchangeable; we enforce an order to avoid this.
% forall(c1 in 1..m_couriers_count, c2 in 1..m_couriers_count where c1 < c2): A loop that
% iterates over pairs of couriers; The condition c1 < c2 ensures that the comparison is only made once between each pair
% (max(courier_weight[c1], courier_weight[c2]) <= min(l_max_loads[c1], l_max_loads[c2]))
% ensures that the heavier of the two couriers' actual loads is still less than or equal to the smaller of the two couriers' maximum capacities.
% lex_less(row(order_of_delivery, c1), row(order_of_delivery, c2))
% This part enforces lexicographical ordering between the delivery sequences (order_of_delivery) of courier c1 and courier c2 if the load condition is met.
constraint symmetry_breaking_constraint(
    forall(c1 in 1..m_couriers_count, c2 in 1..m_couriers_count where c1 < c2)
    (
      (max(courier_weight[c1], courier_weight[c2]) <= min(l_max_loads[c1], l_max_loads[c2])) ->
      (lex_less(row(order_of_delivery, c1), row(order_of_delivery, c2))))
);

% The goal is to minimize the maximum distance traveled by any courier
maximum_distance = max(i in 1..m_couriers_count)(courier_distances[i]);

solve minimize maximum_distance;  % This is a simple and direct approach

% Other potential strategies to reduce solving time, though the direct approach is nearly optimal
% solve 
% :: int_search(
%     [order_of_delivery[i,j] | i in 1..m_couriers_count, j in 1..n_items_count+2],  % Variables for decision-making - Focus first on the first courier's path, then the second, etc.
%     input_order,      % Variable selection strategy: input order. Alternatives include first_fail or input_order
%     indomain_min,     % Value selection strategy: minimum value first. Alternatives include indomain_random or indomain_median.
%     complete          % Apply this strategy across the entire search process
% ) 
% minimize maximum_distance;

output 
[
  "maximum_distance = ", show(maximum_distance), ";\n",
  "order_of_delivery = [\n",
  concat([ show([order_of_delivery[courier,j] | j in 1..n_items_count+2]) ++ if courier != m_couriers_count then ",\n" else "\n" endif | courier in 1..m_couriers_count ]),
  "];\n",
  "courier_distances = ", show(courier_distances), ";\n"
];
% output 
%     [show(maximum_distance)] ++ [ "\n"] ++
%     [show(order_of_delivery)] ++ [ "\n"] ++
%     [show(courier_distances)] ++ [ "\n"]
% ;
