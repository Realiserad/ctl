% Computation Tree Logic Tester
% Bastian Fredriksson (Christmas -13)

% Unit test
test:-
	directory_files('./tests', DirectoryFiles),
	subtract(DirectoryFiles, [.,..], Files),
	run_tests(Files).

run_tests([]).

run_tests([File|Files]):-
	% Valid samples should begin with lowercase 'v'.
	sub_atom(File, 0, 1, _, v),
	string_to_atom('./tests/', Dir),
	atom_concat(Dir, File, Path),
	write('Valid formula: '), write(File), nl,
	verify(Path),
	run_tests(Files).
	
run_tests([File|Files]):-
	% Invalid samples should begin with lowercase 'i'.
	sub_atom(File, 0, 1, _, i),
	string_to_atom('./tests/', Dir),
	atom_concat(Dir, File, Path),
	write('Invalid formula: '), write(File), nl,
	\+verify(Path),
	run_tests(Files).

% Load model, initial state and formula from file.
% T = Transitions
% L = Labeling
% S = State
% F = CTL Formula
verify(Input):-
	see(Input),
	read(T),
	read(L),
	read(S),
	read(F),
	seen,
	check(T, L, S, [], F).

% AX
check(T, L, S, U, ax(F)):-
	member([S, States], T),
	check_all(T, L, States, U, F).

% EX
check(T, L, S, U, ex(F)):-
	member([S, States], T),
	member(Candidate, States),
	check(T, L, Candidate, U, F).

% AG
check(T, L, S, U, ag(F)):-
	member(S, U); % Path checked
	check(T, L, S, [], F),
	check(T, L, S, [S|U], ax(ag(F))).

% EG
check(T, L, S, U, eg(F)):-
	member(S, U);
	check(T, L, S, [], F),
	check(T, L, S, [S|U], ex(eg(F))),
	!.
	
% AF
check(T, L, S, U, af(F)):-
	\+member(S, U),
	check(T, L, S, [], F);
	\+member(S, U),
	check(T, L, S, [S|U], ax(af(F))).

% EF
check(T, L, S, U, ef(F)):-
    \+member(S, U),
	check(T, L, S, [], F);
	\+member(S, U),
	check(T, L, S, [S|U], ex(ef(F))).
	
% AND
check(T, L, S, [], and(F,G)):- 
	check(T, L, S, [], F),
	check(T, L, S, [], G).

% OR
check(T, L, S, [], or(F, G)):-
	check(T, L, S, [], F);
	check(T, L, S, [], G).

% M, S |- ¬F
check(_, L, S, [], neg(F)):-
	member([S, Atoms], L),
	\+member(F, Atoms).

% M, S |- F
check(_, L, S, [], F):- 
	member([S, Atoms], L),
	member(F, Atoms).

check_all(_, _, [], _, _). % All states checked.
check_all(T, L, [State|States], U, F):-
	check(T, L, State, U, F), 
	!,
	check_all(T, L, States, U, F).
