c     ****************************************************************
c     *                                                              *
c     *                      subroutine incoor                       *
c     *                                                              *
c     *                       written by : bh                        *
c     *                                                              *
c     *                   last modified : 02/17/90                   *
c     *                                                              *
c     *     this subroutine supervises and conducts the input of     *
c     *     coordinate data pertaining to the structure's nodes.     *
c     *                                                              *
c     ****************************************************************
c
c
c
      subroutine incoor( sbflg1, sbflg2 )
c
      use main_data, only : crdmap
c
      implicit integer (a-z)
      include 'common.main'
      double precision
     &  x(ndim), xcur, dumd, zero
      real dumr
      character :: dums
      logical laybel, sbflg1, sbflg2, matchs, numd, integr,
     &        endcrd, true, clear_x
      dimension defalt(ndim)
      data zero /0.0/
c
c                       if the subroutine has been previously
c                       entered and exited, then there was an
c                       error in the data of the last processed
c                       card. specifically, that error was the
c                       omission of the node number for coordinate
c                       data. under this circumstance, print an
c                       error message and continue with input.
c                       
      if(sbflg1) then
         call errmsg(23,dum,dums,dumr,dumd)
         go to 405
      end if
c
c                       initialize temporary coordinate vector and
c                       default dof ordering vector. set indicator
c                       that sufficient coordinate data has been 
c                       input to true. if the clear flag is on,
c                       we zero the coordinate data after each
c                       node value is enterd.
c                        
      x(1)      = zero
      x(2)      = zero
      x(3)      = zero
      defalt(1) = 1
      defalt(2) = 2
      defalt(3) = 3
      clear_x   = .false.
      if ( matchs('clear',5) ) clear_x = .true.
c
c                       read in the coordinates node by node
c                       
 405  call readsc
c
c **********************************************************************
c *                                                                    *
c *                     set default orderings of non-labelled input    *
c *                     data                                           *
c *                                                                    *
c **********************************************************************
c
c
 410  continue
      if ( matchs('dump',4) ) then
        write(out,9500)
        do node = 1, nonode
          if ( crdmap(node) .ne. 0 ) then
            write(out,9510) node, c(crdmap(node)), c(crdmap(node)+1),
     &                      c(crdmap(node)+2)
          end if
        end do
        go to 405
      end if
c
       if(matchs('default',7)) then
c
         defpos= 1
         curval= 0
c
 411     if(matchs('x',1)) go to 412
         if(matchs('y',1)) go to 413
         if(matchs('z',1)) go to 414
c
         if(endcrd(dum)) then
            call errmsg(12,dum,dums,dumr,dumd)
            go to 405
         else
            call errmsg(13,dum,dums,dumr,dumd)
            go to 405
         end if
c
 412     continue
         defalt(defpos)= 1
         go to 415
c
 413     continue
         defalt(defpos)= 2
         go to 415
c
 414     continue
         defalt(defpos)= 3
         go to 415
c
 415     continue
c
c                       check to make sure the default assignments
c                       haven't been repeated                       
c
         if(curval.eq.defalt(defpos)) then
            call errmsg(14,dum,dums,dumr,dumd)
         else
            curval= defalt(defpos)
         end if
c
         defpos= defpos+1
         if(defpos.le.3) then
            go to 411
         else
            go to 405
         end if
c
      end if
c
c
c **********************************************************************
c *                                                                    *
c *                     read in node. if no node is given, then        *
c *                     either the node has been forgotten or          *
c *                     coordinate input has ended. in either          *
c *                     case, set sbflg1 to true and exit the          *
c *                     subroutine. if the node has been forgotten,    *
c *                     then the rest of the line will be skipped.     *
c *                                                                    *
c **********************************************************************
c
c
      if(.not.integr(node)) then                       
c
         go to 9999
c
      else   
c
c                       there is a node.
c
c
c                       check that the node input does not exceed
c                       the number of nodes in the structure.
c
         if ( matchs(',',1) ) call splunj
         if ( node .gt. nonode ) then    
            param= node
            call errmsg(16,param,dums,dumr,dumd)
            go to 405
         end if
c
c                       check that the node input is not negative.
c
         if(node.lt.0) then
            param= node
            call errmsg(58,param,dums,dumr,dumd)
            go to 405
         end if      
c                        
c                       set the coordinate mapping vector to point to
c                       the current node
c
         if(crdmap(node).eq.0) then
            crdmap(node)= crdtop+1
            crdtop= crdtop+3
         end if
c
         dofpos= 1
c
      end if
c
c
c **********************************************************************
c *                                                                    *
c *                     input coordinates.                             *
c *                                                                    *
c **********************************************************************
c
c   
c                       set the label indicator to distinguish
c                       between labeled and unlabeled input
c
      laybel= .false.       
c
 420  if(matchs('x',1)) go to 430
      if(matchs('y',1)) go to 435
      if(matchs('z',1)) go to 440
      if(endcrd(dum)) go to 450
c
c                       a label has been input and processed. a new
c                       label is expected, and has not been found.
c                       
      if(laybel) then
         call errmsg(17,dum,dums,dumr,dumd)
         if(true(dum)) go to 420
      end if
c
c
c **********************************************************************
c *                                                                    *
c *                     nonlabeled input                               *
c *                                                                    *
c **********************************************************************
c
c
 425  if(.not.numd(xcur)) then
c
         if(endcrd(dum)) then
            go to 450        
         else
            call errmsg(18,dum,dums,dumr,dumd)
            if(true(dum)) go to 425                                
         end if
c
      else
c
         if ( matchs(',',1) ) call splunj 
         if(dofpos.le.3) then
            x(defalt(dofpos))= xcur
            dofpos= dofpos+1
            go to 425
         else
            call errmsg(19,dum,dums,dumr,dumd)
            go to 450
         end if
c
      end if
c
c
c **********************************************************************
c *                                                                    *
c *                     labeled input                                  *
c *                                                                    *
c *                     x direction input                              *
c *                                                                    *
c **********************************************************************
c
c
 430  continue
      laybel= .true.
c
c                       place the number input in the x direction
c                       slot in x(). if the entity in the scanner
c                       is not a real number, then don't process
c                       it and return to scan for a new dof label.
c                       if there is an end of card, process the node.
c                       
      if(.not.numd(xcur)) then
c
         if(endcrd(dum)) then
            call errmsg(20,dum,' x ',dumr,dumd)
            go to 450
         else
            call errmsg(21,dum,dums,dumr,dumd)
            if(true(dum)) go to 420
         end if
c
      else
c
         x(1)= xcur
         if ( matchs(',',1) ) call splunj 
         go to 420
c
      end if
c
c
c **********************************************************************
c *                                                                    *
c *                     y direction input                              *
c *                                                                    *
c **********************************************************************
c
c
 435  continue
      laybel= .true.
c
c                       place the number input in the y direction
c                       slot in y(). if the entity in the scanner
c                       is not a real number, then don't process
c                       it and return to scan for a new dof label.
c                       if there is an end of card, process the node.
c                       
      if(.not.numd(xcur)) then
c
         if(endcrd(dum)) then
            call errmsg(20,dum,' y ',dumr,dumd)
            go to 450
         else
            call errmsg(21,dum,dums,dumr,dumd)
            if(true(dum)) go to 420
         end if
c
      else
c
         x(2)= xcur
         if ( matchs(',',1) ) call splunj 
         go to 420
c
      end if
c
c
c **********************************************************************
c *                                                                    *
c *                     z direction input                              *
c *                                                                    *
c **********************************************************************
c
c
 440  continue
      laybel= .true.
c
c                       place the number input in the z direction
c                       slot in z(). if the entity in the scanner
c                       is not a real number, then don't process
c                       it and return to scan for a new dof label.
c                       if there is an end of card, process the node.
c                       
      if(.not.numd(xcur)) then
c
         if(endcrd(dum)) then
            call errmsg(20,dum,' z ',dumr,dumd)
            go to 450
         else
            call errmsg(21,dum,dums,dumr,dumd)
            if(true(dum)) go to 420
         end if
c
      else
c
         x(3)= xcur
         if ( matchs(',',1) ) call splunj 
         go to 420
c
      end if
c
c
c **********************************************************************
c *                                                                    *
c *                     place the contents of the temporary            *
c *                     coordinate vector x in the global coordinate   *
c *                     vector c. note that this temporary vector      *
c *                     will hold any of the previous node's data      *
c *                     that has not been changed.                     *
c *                                                                    *
c **********************************************************************
c
c
 450  continue
      c(crdmap(node))   = x(1)
      c(crdmap(node)+1) = x(2)
      c(crdmap(node)+2) = x(3)
      if ( clear_x ) then
       x(1) = zero
       x(2) = zero
       x(3) = zero
      end if
      go to 405
c
c
c **********************************************************************
c **********************************************************************
c
c
 9999 sbflg1= .true.
      sbflg2= .true.
c
      return
c
 9500 format(/,2x,'*** currently defined nodal coordinates ***')
 9510 format(5x,i6,3f20.8)
c
      end      
