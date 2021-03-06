import React from "react";
import styles from "../shared/MasterDetail.css";
import { withRouter } from "react-router-dom";
import { RouteComponentProps } from "react-router";
import { IPerson } from "../../models/Person";

export default withRouter(PeopleTableRow);

interface IProps extends RouteComponentProps {
  person: IPerson;
  selected?: boolean;
}

function PeopleTableRow(props: IProps) {
  const person = props.person;
  const rowClass = props.selected ? styles.selected : "";
  return (
    <tr
      className={rowClass}
      onClick={() => props.history.push(`/people/${person.id}`)}
    >
      <td>{`${person.last_name}, ${person.first_name}`}</td>
      {/* <td>
        <StyledText styleClass="subdued">
          {person.organizations
            .map(org => {
              return org.name;
            })
            .join(", ")}
        </StyledText>
      </td> */}
    </tr>
  );
}
