function result = isAnApplicationState(thing)
   result = isequal(thing,'uninitialized') || ...
            isequal(thing,'no_mdf') || ...
            isequal(thing,'idle') || ...
            isequal(thing,'running') || ...
            isequal(thing,'test_pulsing') ;
end
