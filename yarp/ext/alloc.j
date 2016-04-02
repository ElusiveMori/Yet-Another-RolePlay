// credit to: nestharus
// had to clean up garbage because it took up too much space

library Alloc
	module Alloc
		private static integer array recycler
		
		static method allocate takes nothing returns thistype
			local thistype this = recycler[0]
			
			if (recycler[this] == 0) then
				set recycler[0] = this + 1
			else
				set recycler[0] = recycler[this]
			endif
			
			return this
		endmethod
		
		method deallocate takes nothing returns nothing
			set recycler[this] = recycler[0]
			set recycler[0] = this
		endmethod

		private static method onInit takes nothing returns nothing
			set recycler[0] = 1
		endmethod
	endmodule
endlibrary