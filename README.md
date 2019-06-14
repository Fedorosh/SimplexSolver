# Metody-Optymalzacji
Projekt stworzony na zajęcia z Metod Optymalizacji

# Przykład użycia:

```
using JuMP
include("Simplex.jl") // include this

model = Model() // no argument needed in model constructor

@variable(model, 0 <= x1 )
@variable(model, 0 <= x2 )

@objective(model, Max, 340*x1 + 404*x2 )

@constraint(model, 420x1 + 760x2 <= 5480.0)
@constraint(model, 9x1 + 5x2 <= 61.0)
```

// pass model object to the 2 fuctions that user interface consists of as of now
showModel(model)
println()
solve(model)

# Output:
```
showModel():

Objective:
Max: 340 x1 + 404 x2

Constraints:
0.0 < x1
0.0 < x2
420.0x1 + 760.0x2 <= 5480.0
9.0x1 + 5.0x2 <= 61.0

solve():

Iteration nr 3
Problem:
    [340.0, 404.0, 0.0, 0.0]
404.0 [0.0, 1.0, 0.00189873, -0.0886076, 5.0]
340.0 [1.0, 0.0, -0.00105485, 0.160338, 4.0]
    [340.0, 404.0, 0.408439, 18.7173]
    [0.0, 0.0, -0.408439, -18.7173]  fval = 3380.0
Column: 1
Row: 2
```
