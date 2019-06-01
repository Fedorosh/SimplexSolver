function showObj(model::Model)
    if objective_sense(model) == MOI.MAX_SENSE
        print("Max: ")
    elseif objective_sense(model) == MOI.MIN_SENSE
        print("Min: ")
    end
    f = objective_function(model)
    println(f)
    # println(f.terms.keys)
    # println(f.terms.vals)
end

function showConstr(model::Model)
    less_than_constraints = all_constraints(model, GenericAffExpr{Float64,VariableRef}, MOI.LessThan{Float64})
    for i in 1:length(less_than_constraints)
        con = constraint_object(less_than_constraints[i])
        for j in 1:length(con.func.terms.keys)
            if j != 1
                print(" + ")
            end
            print(con.func.terms.vals[j], con.func.terms.keys[j])
        end
        println(" <= ", con.set.upper)
    end

    greater_than_constraints = all_constraints(model, GenericAffExpr{Float64,VariableRef}, MOI.GreaterThan{Float64})
    for i in 1:length(greater_than_constraints)
        con = constraint_object(greater_than_constraints[i])
        for j in 1:length(con.func.terms.keys)
            if j != 1
                print(" + ")
            end
            print(con.func.terms.vals[j], con.func.terms.keys[j])
        end
        println(" >= ", con.set.lower)
    end

    equal_to_constraints = all_constraints(model, GenericAffExpr{Float64,VariableRef}, MOI.EqualTo{Float64})
    for i in 1:length(equal_to_constraints)
        con = constraint_object(equal_to_constraints[i])
        for j in 1:length(con.func.terms.keys)
            if j != 1
                print(" + ")
            end
            print(con.func.terms.vals[j], con.func.terms.keys[j])
        end
        println(" = ", con.set.value)
    end
end

function  showVarConstr(model::Model)
    allVars = all_variables(model)
    for i in 1:length(allVars)
        var = allVars[i]

        if is_integer(var)
            print("Int: ")
        elseif is_binary(var)
            print("Bin: ")
        end

        if has_lower_bound(var)
            print(lower_bound(var), " < ")
        end
        print(var)
        if has_upper_bound(var)
            print(" < ", upper_bound(var))
        end
        if is_fixed(var)
            print(" = ", fix_value(var))
        end
        println()
    end
end

function showModel(model::Model)
    clearconsole()
    println("Objective:")
    showObj(model)
    println()
    println("Variable constraints:")
    showVarConstr(model)
    println()
    println("Constraints:")
    showConstr(model)
end

function addKeys(vars, constraints, number_of_constraints)
    for i in 1:number_of_constraints
        con = constraint_object(constraints[i])
        for j in 1:length(con.func.terms.keys)
            if !haskey(vars, con.func.terms.keys[j])
                vars[con.func.terms.keys[j]] = length(vars) + 1
            end
        end
    end
end

function buildMatrix(model::Model)
    # get all constraints
    less_than_constraints = all_constraints(model, GenericAffExpr{Float64,VariableRef}, MOI.LessThan{Float64})
    greater_than_constraints = all_constraints(model, GenericAffExpr{Float64,VariableRef}, MOI.GreaterThan{Float64})
    equal_to_constraints = all_constraints(model, GenericAffExpr{Float64,VariableRef}, MOI.EqualTo{Float64})

    # numbers of different kinds of constraints
    num_less = length(less_than_constraints)
    num_great = length(greater_than_constraints)
    num_eq = length(equal_to_constraints)
    num_constr = num_less + num_great + num_eq

    # number all variables in the model from 1 to n
    vars = Dict()
    addKeys(vars, less_than_constraints, num_less)
    addKeys(vars, greater_than_constraints, num_great)
    addKeys(vars, equal_to_constraints, num_eq)

    # number of variables
    num_var = length(vars)

    # building a simplex matrix
    # make enough space for all constraints, variables and helping variables
    matrix_vars = num_var + num_less + num_great
    matrix = zeros(num_constr, matrix_vars + 1) # + 1 is for the absolute term
    println(size(matrix))

    # iterate through constraints to fill up the matrix
    num_helper = 0
    # less than constraints
    for i in 1:num_less
        con = constraint_object(less_than_constraints[i])
        len = length(con.func.terms.keys)
        # normal variables
        for j in 1:len
            index = vars[ con.func.terms.keys[j] ]
            matrix[i, index] = con.func.terms.vals[j]
        end
        # helping variable
        num_helper += 1
        matrix[i,len + num_helper] = 1
        # absolute term
        matrix[i, end] = con.set.upper
    end
    # greater than constraints
    for i in 1:num_great
        con = constraint_object(greater_than_constraints[i])
        len = length(con.func.terms.keys)
        # normal variables
        for j in 1:len
            index = vars[ con.func.terms.keys[j] ]
            matrix[i + num_less, index] = con.func.terms.vals[j]
        end
        # helping variable
        num_helper += 1
        matrix[i + num_less, len + num_helper] = -1
        # absolute term
        matrix[i + num_less, end] = con.set.lower
    end
    # equal to constraints
    for i in 1:num_eq
        con = constraint_object(equal_to_constraints[i])
        len = length(con.func.terms.keys)
        # normal variables
        for j in 1:len
            index = vars[ con.func.terms.keys[j] ]
            matrix[i + num_less + num_great, index] = con.func.terms.vals[j]
        end
        # absolute term
        matrix[i + num_less + num_great, end] = con.set.value
    end
    return matrix
end

function solve(model::Model)
    matrix = buildMatrix(model)
    println(matrix)
end
