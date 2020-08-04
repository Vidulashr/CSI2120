/*Name: Vidulash R.*/
/*Snum: 8190398*/

/*PLEASE MAKE SURE COST MATRIX FILE IS FOUND IN WORKING DIRECTORY*/
/*AS THIS PROGRAM WILL READ FROM YOUR WORKING DIRECTORY AND WILL PRODUCE*/
/*OUTPUT FILE TO THE WORKING DIRECTORY*/

/*Calculates total cost from given selections in a List*/
calculatecost([], 0).            %Base case   
calculatecost([H|T], Total) :-
   calculatecost(T, Rest),       %Loop
   Total is H + Rest.            %Recursively increment using value of H 

/*Gets value from specified row and col from a given matrix (list of lists)*/
getvalue(L,R,C,X):-
	nth0(R,L,RES1),          %Get row from matrix
        nth0(C,RES1,RES2),       %Get col from matrix
        X = RES2.                %return value

/*Grabs costs values from matrix given list of positions and appends total at the end*/
getcosts(_,[],_,L,R):-
    calculatecost(L,Total),      %When done, calculate cost
    append(L,[Total],Final),     %append end of combination
    R = Final.
getcosts(M,[H|T],Pos,L,R):-
    getvalue(M,Pos,H,V),         %Get the value at the given position
    append(L,[V],N),             %Append it to list
    P is Pos + 1,                %Increment
    getcosts(M,T,P,N,R).         %Loop to get next value at position


/*Generates random list given a list length in a random order*/
generatelist(N,N,T,_,W):-
        W = T.                        %When length of list is met, stop
generatelist(N,Count,T,X,W):-
        makelist(N,L),                %Make a list on given length
        chooserand(L,Ele),            %Choose random value from list
        (member(Ele,T)->              %If present in result list
        generatelist(N,Count,T,X,W);  %Loop again
        append(T,[Ele],X),            %Otherwise, append it to result list
        C is Count+1,                 %Increment
        generatelist(N,C,X,Y,W)).     %Loop to add to list
             
/*Chooses a random element from a given list*/
chooserand([], []).
chooserand(List, E) :-
        length(List, L),             %Get length of given list
        random(0, L, I),             %Randomly select index from 0 to length
        nth0(I, List, E).            %Return value at index

/*Makes a list from 0 - N*/
makelist(N, L):- 
  N1 is N-1,                                   %Subtract 1 from input
  findall(Number, between(0, N1, Number), L).  %Make list from 0 to given -1


/*Generates all index combinations of list for a given length*/
getlistofcombinations(N,L):-
          fact(N,F),                                 %Get factorial of length
          generatecombinations(F,N,0,[],X,Combs),    %Generate all combinations
          L = Combs.                                 
generatecombinations(F,_,F,T,_,W):-
          W = T.
generatecombinations(F,N,Count,T,X,W):-
          generatelist(N,0,[],V,Comb),               %Generate random list 
          (member(Comb,T)->                          %If already in result list
          generatecombinations(F,N,Count,T,X,W);     %Keep generating
          append(T,[Comb],X),                        %Else append it to result list
          C is Count+1,                              %Increment
          generatecombinations(F,N,C,X,Y,W)).        %Loop

/*Calculates factorial of a number*/
fact(0,1).
fact(N,F):-
    N>0,
    N1 is N-1,
    fact(N1,F1),
    F is N*F1.

       
/*Gets all total cost combinations*/
totalcosts(M,Res):-
        length(M,Len),                          %Get length of matrix
        getlistofcombinations(Len,Combs),       %Get list of combinations
        listofcosts(M,Combs,[],Costs),          %Get the costs for the combinations
        Res = Costs.
listofcosts(_,[],Temp,Res):-
       Res = Temp.
listofcosts(M,[H|T],Temp,Res):-        
       getcosts(M,H,0,[],Cost),                %Get cost for specific combination
       append(Temp,[Cost],N),                  %Append it to result 
       listofcosts(M,T,N,Res).                 %Loop


/*Gets the lowest cost combination*/
minimumcost([],_,Comb,Res):-
         Res = Comb.
minimumcost([H|T],Min,Comb,Res):-
         last(H,Cost),                        %Extract cost of combination
         (Min is -1 ->                        %If its the first check, make it min
          minimumcost(T,Cost,H,Res);
         (Cost<Min->                          %Else, if its lower than min, make it min
          minimumcost(T,Cost,H,Res);          %loop
          minimumcost(T,Min,Comb,Res))).

/*Gets all combinations of matrix with the same minimum cost if there are more than 1 assignments*/
allminimum([],_,L,Res):-
         Res = L.
allminimum([H|T],Min,L,Res):-
         last(H,Cost),                          %Get cost of combination
         (Cost is Min ->                        %If its same as found min, append it to result
         append(L,[H],N),
         allminimum(T,Min,N,Res);               %Else keep checking
         allminimum(T,Min,L,Res)).
getminimumcost(M,Res):-
        totalcosts(M,Costs),                    %Make list of all combinations with minimum cost value  
        minimumcost(Costs,-1,[],Min),
        last(Min,Mincost),
        allminimum(Costs,Mincost,[],Final),
        Res = Final.
        


/*All predicates that reads csv file and converts it into a list*/
/*ENSURE THAT COST MATRIX CSV FILE IN LOCATED IN THE WORKING DIRECTORY*/
readCostMatrixCSV(Name, CostMatrix):-
           working_directory(CWD, CWD),          %Get working directory
           text_to_string(CWD,C),                %Concatenate given file name with working directory
           string_concat(C,Name,Filename),       
           csv_read_file(Filename,R,[]),         %Read CSV file using concatenated name
           tolists(R, Lists),                    %Convert to list
           CostMatrix = Lists.                   %Return result
/*Turns csv file into a proper list*/
tolists(Rows, Lists):-
  maplist(tolist, Rows, Lists).                  
tolist(Row, List):-
  Row =.. [row|List].
/*Removes head from a given list*/
omithead([H|T],Rest):-
        Rest = T.
/*Predicate that makes the matrix*/
makeMatrix([],L,Res):-
       Res = L.                 %Returns final matrix with numbers only
makeMatrix([H|T],L,Res):-
       omithead(H,X),           %Remove first element
       append(L,[X],N),         %Append list to result
       makeMatrix(T,N,Res).     %Loop


/*Predicate that extract column names from csv matrix*/
getColNames([H|T],Res):-
          omithead(H,List),      %Remove first element
          Res = List.            %We get list of column names
/*Predicate that extract row names from csv matrix*/
getRowNames([],L,Res):-
        Res = L.                 %We get final list of row names
getRowNames([H|T],L,Res):-
        nth0(0,H,X),             %Get first element from each list
        append(L,[X],N),         %Add to seperate list
        getRowNames(T,N,Res).    %Loop


/*Main predicate that puts all predicates together to find the optimal assignment and cost*/
hungarianMatch(CostMatrix, OptimalAssign, OptimalCost):-
           omithead(CostMatrix,X), 
           makeMatrix(X,[],Matrix),          %Gets ALL number matrix from Cost Matrix derived from file, without row/col
           
           getColNames(CostMatrix,ColNames), %Gets all column names from csv
           omithead(CostMatrix,Rows),        
           getRowNames(Rows,[],RowNames),    %Gets all rows names from csv
           length(Matrix,Len),
           getlistofcombinations(Len,Comb),  %Get matrix length and gets all combinations again

           getminimumcost(Matrix,Result),    %Gets minimum cost list using matrix,predicates above
           last(Result,M),last(M,Cost),      %Get the minimum cost from the result
           
           getallassignements(Matrix,Result,Comb,[],Opt),  %Gets the assignments indexes
           sort(Opt,Unique),                               %Make sure all different assignmenets
           allAssigned(Unique,ColNames,RowNames,[],Final), %Get assignment col and row names using indexes and list of names from above

           OptimalCost = Cost,!,             %Unifies cost and assignments
           member(OptimalAssign,Final).     %If multiple displays all
           

/*Predicates that gets assignement names for the given matrix*/
/*Gets a specific assignment*/
assignement(_,_,[],Temp,Res):-
          Res = Temp.                         %At end return assignment in original combination form
assignement(M, A, [H|T], Temp, Res):-
           getcosts(M,H,0,[],Cost),           %Get original cost for the combination
           (same(A,Cost) ->                   %If found minimum value is the same, add it to result list
           append(Temp, [H], N), 
           assignement(M, A, T,N,Res);        %Loop
           assignement(M,A,T,Temp,Res)).      %Else, dont append but loop
getallassignements(_,[],_,L,Res):-
           Res = L.
getallassignements(M,[H|T],Comb,L,Res):-
           assignement(M,H,Comb,[],X),        %Now get original combination of all assignments
           append(L, X, N),                   %Append each to result list
           getallassignements(M,T,Comb,N,Res).%Loop

/*Checks whether two lists are the exact same*/
same([], []).
same([H1|R1], [H2|R2]):-
    H1 = H2,          %Check if head are the same
    same(R1, R2).     %If they are loop, otherwise fails

/*Extracts the col and row name using assignments*/
toAssigned([],_,_,_,L,_,Res):-
          Res = L.                             %Once went through matrix, return list of named assignments
toAssigned([H|T],Start,ColN,RowN,L,L1,Res):-
          nth0(Start,RowN,R),                  %Start at first row name
          nth0(H,ColN,C),                      %Get column index from assignment and get the column name
          append(L1,[R],I),                    %Append row to result
          append(I,[C],F),                     %Append col to result
          append(L,[F],N),                     %Append this list of named assignment to final result 
          S is Start + 1,                      %Increment row
          toAssigned(T,S,ColN,RowN,N,L1,Res).  %Loop

/*Extracts all col and row names for assignments*/
allAssigned([],_,_,L,Res):-
         Res = L.                              %Returns list of all named assignements, if more than 1 was found
allAssigned([H|T],ColN,RowN,L,Res):-
          toAssigned(H,0,ColN,RowN,[],[],A),   %Now do the same with all assignment sets
          append(L,[A],N),                     %Append to list
          allAssigned(T,ColN,RowN,N,Res).


/*All predicates to write the csv file using the optimal assignments provided by hungarian match*/
/*CHECK WORKING DIRECTORY TO SEE THE OUTPUT FILE*/
saveOptimalAssignment(OptimalAssign, Name):-
	writecsvfile(OptimalAssign,Name,N). %Writes file using seperate predicate below
/*Closes file once completed writing*/
writecsvfile2([],N):-
        close(N).              %If done, close 
/*Continues writing file with next element in list*/
writecsvfile2([H|T],N):-
        nth0(0,H,A),           %Get row
        nth0(1,H,B),           %Get col
        write(N,A),            %Write row
        write(N,','),          %Write comma
    	write(N,B),            %Write col
        nl(N),                 %Add space
    	writecsvfile2(T,N).    %Loop
/*Begins writing file using given name*/
writecsvfile([H|T],Name,N):-
        open(Name,write,Out),  %Opens file to write as out
        nth0(0,H,A),           %Get row
        nth0(1,H,B),           %Get col
        write(Out,A),          %Write row
        write(Out,','),        %Write comma
    	write(Out,B),          %Write col
        nl(Out),               %Add Space
    	writecsvfile2(T,Out).  %Pass to next predicate since you cant loop 

/*Completed 7/23/2020*/








