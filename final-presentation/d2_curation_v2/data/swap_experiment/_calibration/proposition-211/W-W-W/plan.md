1. Show that for every tail `Set.Ici N`, the supremum of the product sequence on that tail is bounded above by the product of the two tail suprema:  
   `sSup ((fun n => x n * y n) '' Set.Ici N) ≤ sSup (x '' Set.Ici N) * sSup (y '' Set.Ici N)`.

2. Show that for every tail `Set.Ici N`, the infimum of the product sequence on that tail is bounded below by the product of the two tail infima, using nonnegativity of both sequences:  
   `sInf (x '' Set.Ici N) * sInf (y '' Set.Ici N) ≤ sInf ((fun n => x n * y n) '' Set.Ici N)`.

3. Pass the tail supremum inequality through `⨅ N` to get the limsup product estimate:  
   `seqLimsup (fun n => x n * y n) ≤ seqLimsup x * seqLimsup y`.

4. Pass the tail infimum inequality through `⨆ N` to get the liminf product estimate:  
   `seqLiminf x * seqLiminf y ≤ seqLiminf (fun n => x n * y n)`.

5. Use the general order relation between `seqLiminf` and `seqLimsup` of the same sequence to obtain the middle inequality:  
   `seqLimsup (fun n => x n * y n) ≥ seqLiminf (fun n => x n * y n)`.