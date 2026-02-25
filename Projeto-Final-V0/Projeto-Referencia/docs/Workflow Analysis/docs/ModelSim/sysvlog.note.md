# Technical Note (Adaptado)

For the following, ModelSim PE/SE:
- **is not** *compliant* or
- **has** **incomplete** *support* 

IEEE 1800-2012 SystemVerilog LRM sections:
==========================================================
Section 4: Scheduling semantics
------------------------------------------------------------------------------
4.10      The PLI callback control points
              * Not supported

Section 5: Lexical conventions
------------------------------------------------------------------------------
5.12      Attributes
			 * Default attribute type not supported.

Section 8: Classes
------------------------------------------------------------------------------
8.3       Syntax
              * rand and randc only supported in Questa
              * No nesting of parameterized class declarations
8.23      Out-of-block declarations
              * Lifetime of method cannot be changed with external definition
                from default lifetime of the class

Section 9: Processes
------------------------------------------------------------------------------
9.4.2.4   Sequence events
              * Only supported in Questa
9.4.4     Level-sensitive sequence controls
			  * Only supported in Questa

Section 10: Procedural statements and control flow
------------------------------------------------------------------------------
10.6.1    Procedural assign and deassign statement
              * Not removed. 

Section 11: Operators and Expressions
------------------------------------------------------------------------------
11.4.13   Set membership operator
              * Wild card semantic of inside operator in a constraint not
                supported
11.9      Tagged union expressions & member access
              * Void members are not supported
11.11     Operator overloading
              * Not supported

Section 15: Interprocess synchronization and communication
------------------------------------------------------------------------------
15.5.4    Event sequencing: wait_order()
              * Not supported

Section 16: Assertions
------------------------------------------------------------------------------
          * Only supported in Questa

Section 17: Checkers
------------------------------------------------------------------------------
          * Only supported in Questa
		  * Randomization of free variables not supported.

Section 18: Constrained random value generation
------------------------------------------------------------------------------
          * Only supported in Questa

Section 19: Functional coverage
------------------------------------------------------------------------------
          * Only supported in Questa

Section 20: Utility system tasks and system functions
------------------------------------------------------------------------------
20.9      Severity tasks ($fatal, $error, $warning, $info)
              * Only supported in Questa
20.10     Elaboration system tasks ($fatal, $error, $warning, $info)
              * Only supported in Questa
20.11     Assertion control system tasks ($assertion, $assertoff, $assertkill)
              * Only supported in Questa
20.12     Assertion action control system tasks ($assertpasson, $assertpassoff)
              * Not supported
20.13     Assertion system functions ($onehot, $onehot0, $isunknown)
              * Only supported in Questa
20.15     Probabilistic distribution functions
              * Only supported in Questa
20.14     Coverage system functions
              * Only supported in Questa

Section 21: I/0 system tasks and system functions
-----------------------------------------------------------------------------
          * Enhancements to system tasks not supported

Section 23: Modules and Hierarchy
------------------------------------------------------------------------------
23.2      Port declarations
              * Complex named Port declarations not supported, for example:
              
```verilog
	module m (input .in(w_in),output .out(r_out));
		wire w_in;
		reg r_out;
	endmodule
	module m (input .P1(input int a));
		logic [7:0] r;
	endmodule
	module m (input .P1(r[5:3]),.P2(r[1]),output .c(r[2:0]));
		logic [7:0] r = 8'b00000000;
	endmodule
	module m (input .P1(r),.P2(r[1]),output int a);
		logic [7:0] r;
	endmodule

```
Section 24: Programs
------------------------------------------------------------------------------
          * Only supported in Questa

Section 27 - 30: API's
------------------------------------------------------------------------------
27        SystemVerilog VPI object model
              * Partially supported, see VPI technote
28        SystemVerilog assertion API
              * Not supported
29        SystemVerilog code coverage control and API
              * Not supported
30        SystemVerilog data read API
              * Not supported

Section 33: Configuring the contents of a design
------------------------------------------------------------------------------
33.3      Libraries
              * Configurations do not support interfaces
33.4.3    Setting parameters in configurations
              * Not supported

Annex A - K
------------------------------------------------------------------------------
F.12      SV3.1a-compatible access to packed data (deprecated functionality)
              * Not supported
F.12.1    Determining the compatibility level of an implementation
              * Not supported
F.12.2    svdpi.h definitions for SV3.1a-style packed data processing
              * Not supported
F.12.3    Source-level compatibility include file svdpi_src.h
              * Not supported
F.12.4    Example 9 - Deprecated SV3.1a binary compatible application
              * Not supported
F.12.5    Example 10 - Deprecated SV3.1a source compatible application
              * Not supported
F.12.6    Example 11 - Deprecated SV3.1a binary compatible calls of export
          functions
              * Not supported
I         sv_vpi_user.h
              * Not supported
