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

function solve(model::Model)

end
