# Fibonacci-with-verilog

Implementing Fibonacci with stack with verilog.Datapath and controller exits in './Doc' folder.Open project and run "do ./sim_top.tcl" in console(Modelsim)


```
int fib (int n) {
  If (n <= 1)
    return 1;
   else {
      If (n > N/2)
          return ((n - 1) * fib (n - 1) + (n - 2) * fib (n - 2));
      else
          return ((n - 2) * fib (n - 1) + (n - 1) * fib (n - 2));
    }
}

```

# Credits
- Morteza Bahjat
- Parna Asadi
