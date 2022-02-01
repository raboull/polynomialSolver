
//Defining macros:
define(loop_iter, x19)											//creates macro for register x19 to be loop_iter
define(x_var, x20)												//creates macro for register x20 to be x_var
define(y_var, x21)												//creates macro for register x21 to be y_var
define(temp, x22)												//creates macro for register x22 to be temp
define(y_max, x23)												//creates macro for register x23 to be y_max


current_vals:   		.string "Values at current iteration:	x=%d	y=%d	max=%d.\n"    //creates the current_vals string in memory

						.balign 4                               //this makes sure that the following instructions that we write are divisible by 4 to alighn word lengths
						.global main                            //pseudo op which sets the start label to main. it will make sure that the main label is picked by the linker

main:           		stp     x29, x30, [sp, -16]!            //stores the contents of the pair of registers to the stack
						mov     x29, sp                         //updates FP to the current SP

						mov     loop_iter, -10                  //initialize the loop iterator (i) to -10
						b	test								//branch to test label

top:															//the beginning of our loop to computer the y values over a range of x values
																//the following block calculates y = -3(x^4)+267(x^2)+47x-43
						mov	x_var, loop_iter					//x_var = loop iter
						mov	y_var, -43							//y_var = -43
						mov	temp, 47							//temp = 47
						madd	y_var, temp, x_var, y_var		//y_var = temp*x_var+y_var = y+47*x
						mul	x_var, x_var, x_var					//x_var = x*x = x^2
						mov 	temp, 267						//temp = 267
						madd	y_var, temp, x_var, y_var		//y_var = temp*x_var+y_var = y+267*(x^2) = 267(X^2)+47x-43
						mul	x_var, x_var, x_var					//x_var = (x^2)*(x^2) = x^4
						mov	temp, -3							//temp = -3
						madd	y_var, temp, x_var, y_var		//y_var = temp*x_var+y_var = -3(x^4)+267(x^2)+47x-43

																//initialize the max value (x23) if this is the first iteration of the loop
after_calc:				cmp	loop_iter, -10						//compare x19 with -10
						b.eq	update_max						//branch to the initialize_max label if x19 is equal to -10

																//update max value (x23) after the first iteration
						cmp	y_var, y_max 						//compare x21 with x23
						b.gt 	update_max						//branch to the update_max label if x21 is greater than x23

						b	display_iter_result					//branch to the display_iter_result label without updating the current max value

update_max:             mov     y_max, y_var					//load the computed y value into x23
                        b       display_iter_result             //branch to display_iter_result label

display_iter_result:    adrp    x0, current_vals                //Arg 1: address of the current_vals string
                        add     x0, x0, :lo12:current_vals      //complete the address location
                        mov     x1, x19                         //Arg 2: x value
                        mov     x2, x21                         //Arg 3: y value
                        mov     x3, x23                         //Arg 4: current max value
                        bl      printf							//function call

                        add     loop_iter, loop_iter, 1			//increment the value of our x variable stored in register x_19 by 1
test:                   cmp     loop_iter, 10					//make a conditional comparison at the bottom of our loop, compare x19 with 10
                        b.le    top                             //branch to the top label if the value stored in register x19 is smaller than or equal to 10

																//statements that follow the loop
done:           		ldp     x29, x30, [sp], 16              //restores the state of the FP and LR registers
						ret                             		//returns control to the calling code (in OS)

