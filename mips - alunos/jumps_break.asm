addi $2, $2, 1	
j first_jump
addi $2, $2, 2

first_jump:
jal second_jump		
addi $2, $2, 5	
j end

second_jump:
addi $2, $2, 3
jr $31		

end:
