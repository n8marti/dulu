import React from "react";
import TextOrEditText from "../shared/TextOrEditText";
import TextOrYesNo from "../shared/TextOrYesNo";
import TextOrSelect from "../shared/TextOrSelect";
import TextOrInput from "../shared/TextOrInput";
import SearchTextInput from "../shared/SearchTextInput";

function PersonBasicInfo(props) {
  const t = props.t;
  const person = props.person;
  const home_country = person.home_country || { id: null, name: "" };

  return (
    <table className="table">
      <tbody>
        <tr>
          <th>{t("Home_country")}</th>
          <td>
            <TextOrInput editing={props.editing} text={home_country.name}>
              <SearchTextInput
                text={home_country.name}
                queryPath="/api/countries/search"
                updateValue={country =>
                  props.updatePerson({
                    home_country: country,
                    country_id: country.id
                  })
                }
                allowBlank
              />
            </TextOrInput>
          </td>
        </tr>
        <tr>
          <th>{t("Email")}</th>
          <td>
            <TextOrEditText
              editing={props.editing}
              value={person.email}
              setValue={value => props.updatePerson({ email: value })}
              t={props.t}
              validateNotBlank={person.has_login}
            />
          </td>
        </tr>
        {!person.isUser && (
          <tr>
            <th>{t("Dulu_account")}</th>
            <td>
              <TextOrYesNo
                editing={props.editing}
                value={person.has_login}
                t={props.t}
                setValue={value => props.updatePerson({ has_login: value })}
              />
            </td>
          </tr>
        )}
        {person.isUser && (
          <React.Fragment>
            <tr>
              <th>{t("dulu_preferred_language")}</th>
              <td>
                <TextOrSelect
                  editing={props.editing}
                  value={person.ui_language}
                  options={{
                    en: "English",
                    fr: "Français"
                  }}
                  setValue={value => props.updatePerson({ ui_language: value })}
                />
              </td>
            </tr>
            <tr>
              <th>{t("Email_frequency")}</th>
              <td>
                <TextOrSelect
                  editing={props.editing}
                  value={person.email_pref}
                  options={t("email_prefs")}
                  setValue={value => props.updatePerson({ email_pref: value })}
                />
              </td>
            </tr>
          </React.Fragment>
        )}
      </tbody>
    </table>
  );
}

export default PersonBasicInfo;
