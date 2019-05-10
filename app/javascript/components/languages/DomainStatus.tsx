import React, { useContext, useState } from "react";
import { ILanguage } from "../../models/Language";
import { Setter, Adder } from "../../models/TypeBucket";
import { IPerson } from "../../models/Person";
import { IOrganization } from "../../models/Organization";
import I18nContext from "../../contexts/I18nContext";
import Spacer from "../shared/Spacer";
import DomainStatusNew from "./DomainStatusNew";
import AddIcon from "../shared/icons/AddIcon";
import { useAPIGet } from "../../util/useAPI";
import { DSICategories } from "../../models/DomainStatusItem";
import DomainStatusX from "./DomainStatusX";
import List from "../../models/List";

export interface DSProps {
  language: ILanguage;
  categories: DSICategories[];

  people: List<IPerson>;
  organizations: List<IOrganization>;

  setLanguage: Setter<ILanguage>;
  addPeople: Adder<IPerson>;
  addOrganizations: Adder<IOrganization>;
}

export default function DomainStatus(props: DSProps) {
  const t = useContext(I18nContext);
  const [addingNew, setAddingNew] = useState(false);

  const actions = {
    setLanguage: props.setLanguage,
    addPeople: props.addPeople,
    addOrganizations: props.addOrganizations
  };

  const loading = useAPIGet(
    `/api/languages/${props.language.id}/domain_status_items`,
    {},
    actions,
    [props.language.id]
  );

  const allDomainStatusItems = props.language.domain_status_items;

  if (props.categories.length == 0) return <p />;

  if (loading && allDomainStatusItems.length == 0) return <p />;

  return (
    <div>
      <h3>
        {t("Status")}
        {props.language.can.update && !addingNew && (
          <React.Fragment>
            <Spacer width="10px" />
            <AddIcon onClick={() => setAddingNew(true)} />
          </React.Fragment>
        )}
      </h3>
      {addingNew ? (
        <DomainStatusNew
          {...props}
          actions={actions}
          cancel={() => setAddingNew(false)}
        />
      ) : (
        <table>
          <tbody>
            {props.categories.map(category => (
              <DomainStatusX
                key={category}
                category={category}
                domainStatusItems={allDomainStatusItems}
                people={props.people}
                organizations={props.organizations}
                basePath={`/languages/${props.language.id}/domain_status_items`}
              />
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}
