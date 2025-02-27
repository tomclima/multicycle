#lui $10, 4097		#linha necessaria pra testar no mars
lui $2, 32767	
addi $2, $2, 32639

sw $2, 140($10)
lw $3, 140($10)
lb $5, 140($10)
