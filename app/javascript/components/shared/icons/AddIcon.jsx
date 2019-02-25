import React from "react";
import Icon from "./Icon";

export default function AddIcon(props) {
  return (
    <Icon {...props} styleClass="iconBlue" data-icon-name="addIcon">
      <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z" />
    </Icon>
  );
}