addi $2, $0, 2
addi $3, $0, 3

beq $2, $2, first_branch
addi $4, $4, 1000
addi $0, $0, 0

first_branch:
bne $2, $3, second_branch
addi $4, $4, 100 
addi $0, $0, 0

second_branch:
beq $2, $3, third_branch
addi $5, $5, 1000

third_branch:
bne $2, $2, end
addi $5, $5, 100

end:
