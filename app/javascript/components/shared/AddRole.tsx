import React, { useState, useContext } from "react";
import SelectInput from "./SelectInput";
import selectOptionsFromObject from "../../util/selectOptionsFromObject";
import AddIcon from "./icons/AddIcon";
import I18nContext from "../../application/I18nContext";

interface IProps {
  addRole: (role: string) => void;
}

export default function AddRole(props: IProps) {
  const t = useContext(I18nContext);
  const [role, setRole] = useState(Object.keys(t("roles"))[0]);

  return (
    <div>
      <SelectInput
        value={role}
        options={selectOptionsFromObject(t("roles"))}
        handleChange={e => setRole(e.target.value)}
      />
      <AddIcon onClick={() => props.addRole(role)} />
    </div>
  );
}
