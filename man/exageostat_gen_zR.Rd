\name{exageostat_gen_zR}
\alias{exageostat_gen_zR}
\title{ Sets up the call to the exageostat_gen_z() C language function accessed via the  R '.C' external function call API }
\description{
  \code{rexageostat_gen_zR} demonstrates the R / C language interface
}

\usage{
rexageostat_gen_zR(n,
		ncores,
		gpus,
		ts,
		p_grid,
		q_grid,
		theta,
		computation,
		dmetric)
}

\arguments{
  \item{ n }{ Integer - number of locations in the incoming data (real mode) or generated data (test mode) }
  \item{ ncores }{ Integer - CPU threads }
  \item{ gpus }{ Integer - GPU threads }
  \item{ ts }{ Integer - tile size }
  \item{ p_grid }{ Integer - (p,q) 2-D block-cyclic distribution grid }
  \item{ q_grid }{ Integer - (p,q) 2-D block-cyclic distribution grid }
  \item{ theta }{ Double vector - initial theta values to generate z }
  \item{ computation }{ String - "exact" or "approx" }
  \item{ dmetric }{ String - "dm" or "gcd" }
  \item{ vecs_out }{ Double vector - locations x, locations y, observations z at (x,y) }

}

\value{
   Returned value: One vector represents: x_out, y_out, and z_out.

}
\author{ Sameh Abdulah, Postdoctoral Fellow, Extreme Computing and Research Center, KAUST \email{sameh.abdulah@kaust.edu.sa}}

\examples{
#
# inline call at R command line or in another R function:
# Provides function arguments for and calls the R exageostat__gen_zR() function.
#
#exageostat_gen_zR(n,
#               ncores,
#               gpus,
#               ts,
#               p_grid,
#		q_grid,
#		theta,
#		computation,
#		dmetric)
}


\keyword{programming}
