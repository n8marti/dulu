import React from 'react'

import IconButton from './IconButton'

/*
    Required props:
        function handleClick
*/

function DeleteIconButton(props) {
    return(
        <IconButton icon="trash" extraClasses="iconButtonDanger" {...props} />
    )
}

export default DeleteIconButton